//
//  FLYUsersService.m
//  Flyy
//
//  Created by Xingxing Xu on 3/5/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYUsersService.h"

@implementation FLYUsersService

+ (instancetype)usersService
{
    return [[FLYUsersService alloc] initWithEndpoint:EP_USER];
}

- (void)createUserWithPhoneHash:(NSString *)phoneHash code:(NSString *)code userName:(NSString *)userName password:(NSString *)password success:(FLYCreateUserSuccessBlock)successBlock error:(FLYCreateuserErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"device_id":[FLYAppStateManager sharedInstance].deviceId,
                             @"phone_hash":phoneHash,
                             @"code":code,
                             @"user_name":userName,
                             @"password":password
                             };
    [manager POST:self.endpoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(operation, responseObject);
    } failure:^(id responseObj, NSError *error) {
        errorBlock(responseObj, error);
        UALog(@"create user error %@", error);
    }];
}

- (void)resetPasswordWithPhoneHash:(NSString *)phoneHash code:(NSString *)code password:(NSString *)password success:(FLYResetPasswordSuccessBlock)successBlock error:(FLYResetPasswordErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"device_id":[FLYAppStateManager sharedInstance].deviceId,
                             @"phone_hash":phoneHash,
                             @"code":code,
                             @"password":password
                             };
    [manager POST:EP_USER_RESET parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(operation, responseObject);
    } failure:^(id responseObj, NSError *error) {
        errorBlock(responseObj, error);
    }];
}

- (void)getMeWithsuccessBlock:(FLYGetMeSuccessBlock)successBlock error:(FLYGetMeErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:EP_USER_ME parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(operation, responseObject);
        }
    } failure:^(id responseObj, NSError *error) {
        if (errorBlock) {
            errorBlock(responseObj, error);
        }
    }];
}

+ (void)getUserWithUserId:(NSString *)userId successBlock:(FLYGetUserByUserIdSuccessBlock)successBlock error:(FLYGetUserByUserIdErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endPoint = [NSString stringWithFormat:EP_USER_WITH_USER_ID, userId];
    [manager GET:endPoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(operation, responseObject);
        }
    } failure:^(id responseObj, NSError *error) {
        if (errorBlock) {
            errorBlock(responseObj, error);
        }
    }];
}

+ (void)renameUserWithNewUsername:(NSString *)newUsername successBlock:(FLYRenameSuccessBlock)successBlock error:(FLYRenameErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"new_user_name":newUsername};
    [manager POST:EP_USER_RENAME parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(operation, responseObject);
        }
    } failure:^(id responseObj, NSError *error) {
        if (errorBlock) {
            errorBlock(responseObj, error);
        }
    }];
}

+ (void)followUserByUserId:(NSString *)userId isFollow:(BOOL)isFollow successBlock:(FLYFollowUserByUserIdSuccessBlock)successBlock error:(FLYFollowUserByUserIdErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endPoint = [NSString stringWithFormat:EP_USER_FOLLOW_BY_USER_ID, userId];
    if (isFollow) {
        [manager PUT:endPoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (successBlock) {
                successBlock(operation, responseObject);
            }
        } failure:^(id responseObj, NSError *error) {
            if (errorBlock) {
                errorBlock(responseObj, error);
            }
        }];
    } else {
        [manager DELETE:endPoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (successBlock) {
                successBlock(operation, responseObject);
            }
        } failure:^(id responseObj, NSError *error) {
            if (errorBlock) {
                errorBlock(responseObj, error);
            }
        }];
    }
}

+ (void)getFollowingWithUserId:(NSString *)userId firstPage:(BOOL)first cursor:(NSString *)cursor successBlock:(FLYGetFollowerListSuccessBlock)successBlock errorBlock:(FLYGetFollowerListErrorBlock)errorBlock
{
    NSString *endpoint = [NSString stringWithFormat:EP_USER_FOLLOWINGS, userId];
    [FLYUsersService getUsersWithEndpoint:endpoint userId:userId firstPage:first cursor:cursor successBlock:successBlock errorBlock:errorBlock];
}

+ (void)getFollowersWithUserId:(NSString *)userId firstPage:(BOOL)first cursor:(NSString *)cursor successBlock:(FLYGetFollowerListSuccessBlock)successBlock errorBlock:(FLYGetFollowerListErrorBlock)errorBlock
{
    NSString *endpoint = [NSString stringWithFormat:EP_USER_FOLLOWERS, userId];
    [FLYUsersService getUsersWithEndpoint:endpoint userId:userId firstPage:first cursor:cursor successBlock:successBlock errorBlock:errorBlock];
}

+ (void)getUsersWithEndpoint:(NSString *)ep userId:(NSString *)userId firstPage:(BOOL)first cursor:(NSString *)cursor successBlock:(FLYGetFollowerListSuccessBlock)successBlock errorBlock:(FLYGetFollowerListErrorBlock)errorBlock
{
    NSDictionary *params = [NSDictionary new];
    if (first) {
        params = @{@"limit":@(kUserFollowingsPaginationCount)};
    } else {
        params = @{@"limit":@(kUserFollowingsPaginationCount), @"cursor":cursor};
    }
    

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:ep parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorBlock) {
            errorBlock(operation, error);
        }
    }];
}

+ (void)updateTextBio:(NSString *)textBio isDelete:(BOOL)isDelete successBlock:(FLYGenericSuccessBlock)successBlock error:(FLYGenericErrorBlock)errorBlock
{
    if (!isDelete) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *params = @{@"text_bio":textBio};
        [manager PUT:EP_USER_TEXT_BIO parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (successBlock) {
                successBlock(operation, responseObject);
            }
        } failure:^(id responseObj, NSError *error) {
            if (errorBlock) {
                errorBlock(responseObj, error);
            }
        }];
    } else {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager DELETE:EP_USER_TEXT_BIO parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (successBlock) {
                successBlock(operation, responseObject);
            }
        } failure:^(id responseObj, NSError *error) {
            if (errorBlock) {
                errorBlock(responseObj, error);
            }
        }];
    }
}

+ (void)updateAudioBioWithMediaId:(NSString *)mediaId audioDuration:(NSInteger)audioDuration successBlock:(FLYGenericSuccessBlock)successBlock error:(FLYGenericErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"media_id":mediaId, @"audio_duration":@(audioDuration)};
    [manager PUT:EP_USER_AUDIO_BIO parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(operation, responseObject);
        }
    } failure:^(id responseObj, NSError *error) {
        if (errorBlock) {
            errorBlock(responseObj, error);
        }
    }];
}

@end
