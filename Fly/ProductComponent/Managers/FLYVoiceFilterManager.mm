//
//  FLYVoiceFilterManager.m
//  Flyy
//
//  Created by Xingxing Xu on 3/7/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYVoiceFilterManager.h"
#include "ZTX.h"
#import "EAFRead.h"
#import "EAFWrite.h"
#include "Utilities.h"
#import "FLYFileManager.h"
#import "FLYAudioManager.h"

double gExecTimeTotal = 0.;

@interface FLYVoiceFilterManager()

@property (nonatomic) NSURL *inUrl;
@property (nonatomic) NSURL *outUrl;
@property (nonatomic) EAFRead *reader;
@property (nonatomic) EAFWrite *writer;

@property (nonatomic) float percent;

@end

@implementation FLYVoiceFilterManager

- (instancetype)initWithEffect:(FLYVoiceFilterEffect)effect
{
    if (self = [super init]) {
        _effect = effect;
        NSString *inputSound = [[FLYFileManager audioCacheDirectory] stringByAppendingPathComponent:kRecordingAudioFileName];
        NSString *outputSound = [[FLYFileManager audioCacheDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d%@", kRecordingAudioFileNameAfterFilter, (int)_effect, kAudioFileExt]];
        _inUrl = [NSURL fileURLWithPath:inputSound];
        _outUrl = [NSURL fileURLWithPath:outputSound];
        _reader = [[EAFRead alloc] init];
        _writer = [[EAFWrite alloc] init];
    }
    return self;
}

- (void)applyFiltering:(FLYVoiceFilterEffect)filter
{
    [NSThread detachNewThreadSelector:@selector(_processThread:) toTarget:self withObject:@(filter)];
}

- (void)_processThread:(NSNumber *)filterValue
{
    
    NSInteger value = [filterValue integerValue];
    NSDictionary *pitchParams = [self _pitchParams:value];
    if (!pitchParams) {
        NSLog(@"pitch params are nil");
        return;
    }
    
    int numChannels = (int)ZtxValidateNumChannels(2);		// ZtxLE allows mono only
    float sampleRate = 44100.;
    
    // open input file
    [_reader openFileForRead:_inUrl sr:sampleRate channels:numChannels];
    
    // create output file (overwrite if exists)
    [_writer openFileForWrite:_outUrl sr:sampleRate channels:numChannels wordLength:16 type:kAudioFileM4AType];
    
    // ZTX parameters
    // Here we set our time an pitch manipulation values
    float time      = [[pitchParams objectForKey:@"time"] floatValue];                 // 115% length
    float pitch     = pow(2., [[pitchParams objectForKey:@"pitch"] floatValue]/12.);     // pitch shift (0 semitones)
    float formant   = pow(2., 0/12.);    // formant shift (0 semitones). Note formants are reciprocal to pitch in natural transposing
    
    // First we set up ZTX to process numChannels of audio at 44.1kHz
    // N.b.: The fastest option is kZtxLambdaPreview / kZtxQualityPreview, best is kZtxLambda3, kZtxQualityBest
    // The probably best *default* option for general purpose signals is kZtxLambda3 / kZtxQualityGood
    void *ztx = ZtxCreate(kZtxLambda1, kZtxQualityGood, numChannels, sampleRate, &myReadData, (__bridge void*)self);
    //	void *ztx = ZtxCreate(kZtxLambda3, kZtxQualityBest, numChannels, sampleRate, &myReadData);
    if (!ztx) {
        printf("!! ERROR !!\n\n\tCould not create ZTX instance\n\tCheck number of channels and sample rate!\n");
        printf("\n\tNote that the ZtxLE library supports only\n\tone channel per instance\n\n\n");
        exit(-1);
    }
    
    // Pass the values to our ZTX instance
    ZtxSetProperty(kZtxPropertyTimeFactor, time, ztx);
    ZtxSetProperty(kZtxPropertyPitchFactor, pitch, ztx);
    ZtxSetProperty(kZtxPropertyFormantFactor, formant, ztx);
    
    // upshifting pitch will be slower, so in this case we'll enable constant CPU pitch shifting
    if (pitch > 1.0)
        ZtxSetProperty(kZtxPropertyUseConstantCpuPitchShift, 1, ztx);
    
    // Print our settings to the console
    ZtxPrintSettings(ztx);
    
    NSLog(@"Running ZTX version %s\nStarting processing", ZtxVersion());
    
    // Get the number of frames from the file to display our simplistic progress bar
    SInt64 numf = [_reader fileNumFrames];
    SInt64 outframes = 0;
    SInt64 newOutframe = numf*time;
    long lastPercent = -1;
    _percent = 0;
    
    // This is an arbitrary number of frames per call. Change as you see fit
    long numFrames = 8192;
    
    // Allocate buffer for output
    float **audio = AllocateAudioBuffer((int)numChannels, (int)numFrames);
    
    double bavg = 0;
    
    // MAIN PROCESSING LOOP STARTS HERE
    for(;;) {
        
        // Display ASCII style "progress bar"
        _percent = 100.f*(double)outframes / (double)newOutframe;
        long ipercent = _percent;
        if (lastPercent != _percent) {
//            printf("\rProgress: %3li%% [%-40s] ", ipercent, &"||||||||||||||||||||||||||||||||||||||||"[40 - ((ipercent>100)?40:(2*ipercent/5))] );
            lastPercent = ipercent;
            fflush(stdout);
        }
        
        ZtxStartClock();								// ............................. start timer ..........................................
        
        // Call the ZTX process function with current time and pitch settings
        // Returns: the number of frames in audio
        long ret = ZtxProcess(audio, numFrames, ztx);
        bavg += (numFrames/sampleRate);
        gExecTimeTotal += ZtxClockTimeSeconds();		// ............................. stop timer ..........................................
        
//        printf("x realtime = %3.3f : 1 (DSP only), CPU load (peak, DSP+disk): %3.2f%%\n", bavg/gExecTimeTotal, ZtxPeakCpuUsagePercent(ztx));
        
        // Process only as many frames as needed
        long framesToWrite = numFrames;
        unsigned long nextWrite = (unsigned long)(outframes + numFrames);
        if (nextWrite > newOutframe) {
            framesToWrite = (unsigned long)(numFrames - nextWrite + newOutframe);
        }
        if (framesToWrite < 0) framesToWrite = 0;
        
        // Write the data to the output file
        [_writer writeFloats:framesToWrite fromArray:audio];
        
        // Increase our counter for the progress bar
        outframes += numFrames;
        
        // As soon as we've written enough frames we exit the main loop
        if (ret <= 0) {
            break;
        }
    }
    
    _percent = 100;
    
    
    // Free buffer for output
    DeallocateAudioBuffer(audio, (int)numChannels);
    
    // destroy ZTX instance
    ZtxDestroy( ztx );
    
    // Done!
    NSLog(@"\nDone!");
    
    _reader = nil;
    _writer = nil; // important - flushes data to file
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kVoiceFilterApplied object:self userInfo:@{@"filter_effect":@(self.effect)}];
    // start playback on main thread
//    [self performSelectorOnMainThread:@selector(_playOnMainThread) withObject:self waitUntilDone:NO];
}

- (void)_playOnMainThread
{
    NSString *str = [[FLYFileManager audioCacheDirectory] stringByAppendingPathComponent:kRecordingAudioFileNameAfterFilter];
    [[FLYAudioManager sharedInstance] playAudioWithURLStr:str itemType:FLYPlayableItemRecording];
}

/*
 This is the callback function that supplies data from the input stream/file whenever needed.
 It should be implemented in your software by a routine that gets data from the input/buffers.
 The read requests are *always* consecutive, ie. the routine will never have to supply data out
 of order.
 */
long myReadData(float **chdata, long numFrames, void *userData)
{
    // The userData parameter can be used to pass information about the caller (for example, "self") to
    // the callback so it can manage its audio streams.
    if (!chdata)	return 0;
    
    FLYVoiceFilterManager *instance = (__bridge FLYVoiceFilterManager*)userData;
    if (!instance)	return 0;
    
    // we want to exclude the time it takes to read in the data from disk or memory, so we stop the clock until
    // we've read in the requested amount of data
    gExecTimeTotal += ZtxClockTimeSeconds(); 		// ............................. stop timer ..........................................
    
    OSStatus err = [instance.reader readFloatsConsecutive:numFrames intoArray:chdata];
    
    ZtxStartClock();								// ............................. start timer ..........................................
    
    return err;
}

- (NSDictionary *)_pitchParams:(NSInteger)value
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    switch (value) {
        case FLYVoiceEffectLow1:{
            [dict setObject:@(1.15) forKey:@"time"];
            [dict setObject:@(2) forKey:@"pitch"];
            [dict setObject:@(0) forKey:@"formant"];
            break;
        }
        case FLYVoiceEffectLow2: {
            [dict setObject:@(1) forKey:@"time"];
            [dict setObject:@(3) forKey:@"pitch"];
            [dict setObject:@(0) forKey:@"formant"];
            break;
        }
        case FLYVoiceEffectHigh1: {
            [dict setObject:@(1) forKey:@"time"];
            [dict setObject:@(-2) forKey:@"pitch"];
            [dict setObject:@(0) forKey:@"formant"];
            break;
        }
        case FLYVoiceEffectHigh2: {
            [dict setObject:@(1) forKey:@"time"];
            [dict setObject:@(-1) forKey:@"pitch"];
            [dict setObject:@(0) forKey:@"formant"];
            break;
        }
            
        default:
            break;
    }
    return  dict;
}

- (void)dealloc
{
    _inUrl = nil;
    _outUrl = nil;
    _reader = nil;
    _writer = nil;
}


@end
