//
//  EndPointConstant.h
//  Confessly
//
//  Created by Xingxing Xu on 4/26/14.
//  Copyright (c) 2014 Confess.ly. All rights reserved.
//

@interface EndPointConstant : NSObject

//Base URL
#define DEV_BASE_URL                            @"https://campusab.localhost.com/confessly/"
#define STAGING_BASE_URL                        @"https://staging.confess.ly/"
#define PROD_BASE_URL                           @"https://www.confess.ly/"

//Endpoint
#define GET_ALL_POSTS                           @"topic/all_confessions/recent/%@"
#define GET_TOPIC_DETAIL                        @"topic/view_casual/tid=%@"
#define LOGIN_URL                               @"login/login/"
#define GET_BUDDYLIST                           @"arrowchat/includes/json/receive/receive_buddylist.php"
#define EP_SUBMIT_TOPIC                         @"topic/submit_confession"
#define EP_GET_CONFIG                           @"ep/get_config"
#define EP_VOTE_UP                              @"topic/voteup"
#define EP_SUBMIT_REPLY                         @"reply/submit_reply"
#define EP_REPLY_LIKE                           @"follow/thank"
#define EP_USER_INFO                            @"ep/user_info"
#define EP_CLEAR_NOTIFICATION                   @"ep/clear_notification"
#define EP_GET_MESSAGE_LIST                     @"notification/getMessages/%@"
#define EP_GET_MESSAGE_PAIR                     @"notification/getContactMsgs/uid=%@/%@"
#define EP_SEND_MESSAGE                         @"profile/message"
#define EP_GET_WAKEUP_DATA                      @"ep/get_wakeup_data"
#define EP_SEND_STATUS                          @"arrowchat/includes/json/send/send_status.php"
#define EP_UPDATE_PROFILE                       @"profile/update_profile"
#define EP_AUTH                                 @"login/auth"
#define EP_UPLOAD_IMAGE                         @"setting/upload_image"
#define EP_LOGOUT                               @"user/logout"
#define EP_USER_VISIT                           @"account/visit/uid=%@"
#define EP_GET_REPLIES                          @"account/getReplies/uid=%@/%d"
#define EP_BLOCK_ACCOUNT                        @"account/block"
#define EP_SIGNUP_ACTION                        @"register/register_action"
#define GET_ALL_NOTIFICATIONS                   @"notification/"
#define EP_SET_DEVICE_TOKEN                     @"ep/set_device_token"
#define EP_REPORT                               @"ep/report"
#define EP_SET_DEVICE_INFO                      @"ep/set_device_info"


//Confess.ly URLs
#define EP_URL_CONFESSLY_RULES                  @"https://www.confess.ly/footer/rules"
#define EP_URL_CONFESSLY_PRIVACY_POLICY         @"https://www.confess.ly/footer/privacy"
#define EP_URL_CONFESSLY_TERMS_SERVICE          @"https://www.confess.ly/footer/terms"
#define EP_URL_FORGET_PASSWORD                  @"https://www.confess.ly/login/forgetPwd"
#define EP_URL_SHARE                            @"https://www.confess.ly/topic/view_casual/tid=%lld"


@end
