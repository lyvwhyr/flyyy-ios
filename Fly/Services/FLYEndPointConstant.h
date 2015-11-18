//
//  EndPointConstant.h
//  Confessly
//
//  Created by Xingxing Xu on 4/26/14.
//  Copyright (c) 2014 Confess.ly. All rights reserved.
//

//Endpoint



#define EP_CONFIG                                   @"v1/configs"
#define EP_TAGS                                     @"v1/tags"
#define EP_USERS                                    @"v1/users"

// topics
#define EP_TOPIC                                    @"v1/topics"
#define EP_TOPIC_WITH_GROUP_ID                      @"v1/topics?group_id=%@"
#define EP_TOPIC_ME                                 @"v1/topics/me"
#define EP_TOPIC_LIKE                               @"v1/topics/%@/like"
#define EP_TOPIC_WITH_ID                            @"v1/topics/%@"
#define EP_TOPIC_FLAG                               @"v1/topics/%@/flag"
#define EP_TOPIC_POST                               @"v1/topics"

// topics v2 API
#define EP_TOPIC_V2                                 @"v2/topics"
#define EP_TOPIC_WITH_GROUP_ID_V2                   @"v2/topics?tag_id=%@"
#define EP_TOPIC_MINE                               @"v2/topics?filter=by_tags"

// reply
#define EP_REPLY_WITH_TOPIC_ID                      @"v1/topics/%@"
#define EP_REPLY_ME                                 @"v1/replies/me"
#define EP_REPLY_LIKE                               @"v1/replies/%@/like"
#define EP_REPLY_WITH_ID                            @"v1/replies/%@"
#define EP_REPLY_FLAG                               @"v1/replies/%@/flag"
#define EP_REPLY_POST                               @"v1/replies"

// phone service
#define EP_PHONE                                    @"v1/phones"
#define EP_PHONE_VERIFY                             @"v1/phones/%@/verify"

// users
#define EP_USER                                     @"v1/users"
#define EP_USER_WITH_USER_ID                        @"v1/users/%@"
#define EP_USER_FOLLOW_BY_USER_ID                   @"/v1/users/me/follow/%@"
#define EP_USER_FOLLOWINGS                          @"/v1/users/%@/followees"
#define EP_USER_FOLLOWERS                           @"/v1/users/%@/followers"

// reset password
#define EP_USER_RESET                               @"v1/users/reset"
#define EP_USER_ME                                  @"v1/users/me"
#define EP_USER_RENAME                              @"v1/users/rename"

// login
#define EP_LOGIN                                    @"v1/login"

// username
#define EP_USERNAME                                 @"v1/username"
#define EP_USERNAME_VERIFY                          @"v1/username/%@/verify"

// logout
#define EP_LOGOUT                                   @"v1/logout"

// media
#define EP_MEDIA_SIGN                               @"v1/media/sign"

// device token
#define EP_SET_DEVICE_TOKEN                         @"v1/tokens/%@"
#define EP_DELETE_DEVICE_TOKEN                      @"v1/tokens/%@"

// activities
#define EP_ACTIVITIES_UNREAD_COUNT                  @"/v1/activities/unread_count"
#define EP_ACTIVITIES_MARK_READ                     @"/v1/activities/read"
#define EP_ACTIVITIES_GET                           @"/v1/activities"

// tags
#define EP_TAGS_FOLLOW                              @"v1/tags/%@/join"
#define EP_TAGS_AUTOCOMPLETE                        @"v1/tags/autocomplete/%@"