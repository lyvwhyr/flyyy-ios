//
//  FLYGroupManager.m
//  Fly
//
//  Created by Xingxing Xu on 2/6/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYGroupManager.h"
#import "FLYEndpointRequest.h"
#import "FLYGroup.h"
#import "NSDictionary+FLYAddition.h"

@interface FLYGroupManager()

@property (nonatomic, copy) GroupListServiceResponseBlock groupListServiceResponseBlock;

@end

@implementation FLYGroupManager

+ (instancetype)sharedInstance
{
    static FLYGroupManager *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [FLYGroupManager new];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _groupList = [NSMutableArray new];
        [self _initGroupList];
    }
    return self;
}

- (void)_initGroupList
{
    @weakify(self)
    self.groupListServiceResponseBlock = ^(id response) {
        @strongify(self)
        if (!response || ![response isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSArray *tags = [response fly_arrayForKey:@"tags"];
        NSMutableArray *tempTags = [NSMutableArray new];
        for(int i = 0; i < tags.count; i++) {
            FLYGroup *group = [[FLYGroup alloc] initWithDictory:tags[i]];
            [tempTags addObject:group];
        }
        self.groupList = tempTags;
    };
    [FLYEndpointRequest getGroupListService:self.groupListServiceResponseBlock];
}

@end
