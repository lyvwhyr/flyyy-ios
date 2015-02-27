//
//  FLYLoaderView.m
//  Flyy
//
//  Created by Xingxing Xu on 2/26/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYLoaderView.h"

@implementation FLYLoaderView

- (instancetype)init
{
    if (self = [super init]) {
        self.userInteractionEnabled = NO;
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    }
    return self;
}

@end
