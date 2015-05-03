//
//  EndPointConstant.h
//  Confessly
//
//  Created by Xingxing Xu on 4/26/14.
//  Copyright (c) 2014 Confess.ly. All rights reserved.
//

//Endpoint



#define EP_CONFIG                                   @"v1/configs"
#define EP_GROUPS                                   @"v1/groups"
#define EP_USERS                                    @"v1/users"

// topics
#define EP_TOPIC                                    @"v1/topics"
#define EP_TOPIC_WITH_GROUP_ID                      @"v1/topics?group_id=%@"
#define EP_TOPIC_ME                                 @"v1/topics/me"
#define EP_TOPIC_LIKE                               @"v1/topics/%@/like"
#define EP_TOPIC_WITH_ID                            @"v1/topics/%@"
#define EP_TOPIC_FLAG                               @"v1/topics/%@/flag"
#define EP_TOPIC_POST                               @"v1/topics?user_id=%@"

// reply
#define EP_REPLY_WITH_TOPIC_ID                      @"v1/topics/%@"
#define EP_REPLY_ME                                 @"v1/replies/me"
#define EP_REPLY_LIKE                               @"v1/replies/%@/like"
#define EP_REPLY_WITH_ID                            @"v1/replies/%@"
#define EP_REPLY_FLAG                               @"v1/replies/%@/flag"
#define EP_REPLY_POST                               @"v1/replies?user_id=%@"

// phone service
#define EP_PHONE                                    @"v1/phones"
#define EP_PHONE_VERIFY                             @"v1/phones/%@/verify"

// users
#define EP_USER                                     @"v1/users"
// reset password
#define EP_USER_RESET                               @"v1/users/reset"
#define EP_USER_ME                                  @"v1/users/me"

// login
#define EP_LOGIN                                    @"v1/login"

// username
#define EP_USERNAME                                 @"v1/username"
#define EP_USERNAME_VERIFY                          @"v1/username/%@/verify"

// logout
#define EP_LOGOUT                                   @"v1/logout"

// media
#define EP_MEDIA_SIGN                               @"v1/media/sign"