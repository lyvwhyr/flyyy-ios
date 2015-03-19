//
//  FLYBarButtonItem.h
//  Fly
//
//  Created by Xingxing Xu on 12/5/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//
@class FLYBarButtonItem;

typedef void(^FLYBarButtonItemActionBlock)(FLYBarButtonItem *barButtonItem);

@interface FLYBarButtonItem : UIBarButtonItem

@property (nonatomic, copy) FLYBarButtonItemActionBlock actionBlock;
@property (nonatomic) UIButton *button;

+ (instancetype)barButtonItem:(BOOL)left;
- (instancetype)initWithButton:(UIButton *)button actionBlock:(FLYBarButtonItemActionBlock)actionBlock;
- (instancetype)initWithSide:(BOOL)left;

@end


@interface FLYBackBarButtonItem : FLYBarButtonItem

@end

@interface FLYBlueBackBarButtonItem : FLYBarButtonItem

@end

@interface FLYGroupsButtonItem : FLYBarButtonItem

@end


@interface FLYAddGroupBarButtonItem : FLYBarButtonItem

@end

@interface FLYJoinedGroupBarButtonItem : FLYBarButtonItem

@end

@interface FLYFlagTopicBarButtonItem : FLYBarButtonItem

@end

@interface FLYCatalogBarButtonItem : FLYBarButtonItem

@end

@interface FLYFlagBarButtonItem : FLYBarButtonItem

@end

@interface FLYPostRecordingNextBarButtonItem : FLYBarButtonItem

@end

@interface FLYPostRecordingPostBarButtonItem : FLYBarButtonItem

@end