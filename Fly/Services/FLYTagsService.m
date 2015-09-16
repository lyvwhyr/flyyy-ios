//
//  FLYTagsService.m
//  Flyy
//
//  Created by Xingxing Xu on 9/7/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYTagsService.h"

@implementation FLYTagsService

- (void)nextPageWithCursor:(NSString *)cursor firstPage:(BOOL)first successBlock:(FLYGetGlobalTagsSuccessBlock)successBlock errorBlock:(FLYGetGlobalTagsErrorBlock)errorBlock
{
    NSString *requestEndpoint;
    if (first) {
        requestEndpoint = [NSString stringWithFormat: @"%@?limit=%d", EP_TAGS, kGetGlobalTagsPaginationCount];
    } else if ([cursor length] > 0){
        requestEndpoint = [NSString stringWithFormat: @"%@?limit=%d&cursor=%@", EP_TAGS, kGetGlobalTagsPaginationCount, cursor];
    } else {
        requestEndpoint = [NSString stringWithFormat: @"%@?limit=%d", EP_TAGS, kGetGlobalTagsPaginationCount];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestEndpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorBlock) {
            errorBlock(operation, error);
        }
    }];
}

+ (void)followTagWithId:(NSString *)tagId followed:(BOOL)followed successBlock:(FLYFollowTagSuccessBlock)successBlock errorBlock:(FLYFollowTagErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endpoint = [NSString stringWithFormat:EP_TAGS_FOLLOW, tagId];
    
    if (!followed) {
        [manager PUT:endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (successBlock) {
                successBlock(operation, responseObject);
            }
        } failure:^(id responseObj, NSError *error) {
            if (errorBlock) {
                errorBlock(responseObj, error);
            }
        }];
    } else {
        [manager DELETE:endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

+ (void)autocompleteWithName:(NSString *)name successBlock:(FLYFollowTagSuccessBlock)successBlock errorBlock:(FLYFollowTagErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endpoint = [NSString stringWithFormat:EP_TAGS_AUTOCOMPLETE, name];
    [manager GET:endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
