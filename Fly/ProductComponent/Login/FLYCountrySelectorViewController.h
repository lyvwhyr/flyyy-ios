//
//  FLYCountrySelectorViewController.h
//  Flyy
//
//  Created by Xingxing Xu on 2/28/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYUniversalViewController.h"
#import "FLYSignupPhoneNumberViewController.h"

@interface FLYCountrySelectorViewController : FLYUniversalViewController

@property (nonatomic, copy) FLYCountrySelectedBlock countrySelectedBlock;

@end
