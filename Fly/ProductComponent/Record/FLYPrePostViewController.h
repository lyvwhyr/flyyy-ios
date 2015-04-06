//
//  FLYPrePostViewController.h
//  Fly
//
//  Created by Xingxing Xu on 11/20/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

@class FLYGroup;

#import "FLYUniversalViewController.h"

@interface FLYPrePostViewController : FLYUniversalViewController

@property (nonatomic) NSInteger audioDuration;

// default group
@property (nonatomic) FLYGroup *defaultGroup;

@end
