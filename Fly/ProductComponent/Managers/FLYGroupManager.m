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
        _groupList = [NSArray new];
        [self _initGroupList];
    }
    return self;
}

- (void)_initGroupList
{
    @weakify(self)
    self.groupListServiceResponseBlock = ^(id response) {
        @strongify(self)
        if (!response && ![response isKindOfClass:[NSArray class]]) {
            return;
        }
        response = (NSArray *)response;
        NSMutableArray *tempGroups = [NSMutableArray new];
        for(int i = 0; i < [response count]; i++) {
            FLYGroup *group = [[FLYGroup alloc] initWithDictory:response[i]];
            [tempGroups addObject:group];
        }
        self.groupList = tempGroups;
    };
    [FLYEndpointRequest getGroupListService:self.groupListServiceResponseBlock];
}

@end
