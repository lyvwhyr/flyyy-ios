//
//  FLYCountryListDatasource.m
//  Flyy
//
//  Created by Xingxing Xu on 2/28/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYCountryListDatasource.h"

@implementation FLYCountryListDatasource

- (instancetype)init
{
    if (self = [super init]) {
        [self _parseJson];
    }
    return self;
}

- (void)_parseJson
{
    NSData *popularCountryData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"popular_countries" ofType:@"json"]];
    NSError *parseError = nil;
    NSDictionary *parsedPopularObject = [NSJSONSerialization JSONObjectWithData:popularCountryData options:0 error:&parseError];
    if (parseError) {
        UALog(@"parse popular countries error %@", parseError.userInfo);
    }
    self.popularCountries = (NSArray *)parsedPopularObject;

    NSData *allCountryData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"all_countries" ofType:@"json"]];
    NSError *error = nil;
    NSDictionary *parsedAllObject = [NSJSONSerialization JSONObjectWithData:allCountryData options:0 error:&error];
    if (error) {
        UALog(@"Parse all countries error %@", parseError.userInfo);
    }
    self.allCountries = (NSArray *)parsedAllObject;
}

@end
