
#include "FLYNotificationConstant.h"
#include "FLYErrorCodeConstant.h"
#import "FLYEndPointConstant.h"
#import "FLYURLConstants.h"

#define kFlyyAppID  @"968961270"

#define kStatusBarHeight    20
#define kNavBarHeight       44
#define kTabBarViewHeight   44
#define kTopicPaginationCount 50
#define KReplyPaginationCount 20
#define kStreamingMinimialLen 5
#define kUsernameMaxLen 20

#define kMainScreenWidth      CGRectGetWidth([UIScreen mainScreen].bounds)
#define kMainScreenHeight     CGRectGetHeight([UIScreen mainScreen].bounds)
#define kContainerViewHeight  kMainScreenHeight - kStatusBarHeight - kNavBarHeight - kTabBarViewHeight

#define kNewPostKey @"kNewPostKey"
#define kNewReplyKey @"kNewReplyKey"
#define kTopicOfNewReplyKey @"kTopicOfNewReplyKey"

#define kFeedPlayStateUpdated   @"kFeedPlayStateUpdated"

#define kDownloadAudioLocalPathkey @"kDownloadAudioLocalPathkey"
#define kDownloadAudioTypeKey @"kDownloadAudioTypeKey"

#define kAudioCacheFolder   @"flyyapp.com.audios"
#define kRecordingAudioFileName  @"kRecordingAudioFileName.m4a"
#define kRecordingAudioFileNameAfterFilter @"kRecordingAudioFileNameAfterFilter"
#define kAudioFileExt  @".m4a"

//sign up and login
#define kFromViewControllerKey  @"kFromViewControllerKey"

//phone number
#define kPhoneDialCodeKey @"dial_code"
#define kPhoneCodeKey @"code"
#define kPhoneNameKey @"name"


//Mixpanel event
#define kTrackingEventClientError                               @"client_error"
#define kTrackingEventClientTracking                            @"flyy_client"
#define kTrackingEventClientSuggestTag                          @"suggest_tag"


//Mixpanel properties
#define kTrackingPropertyStatusCode                             @"status_code"
#define kTrackingPropertyErrorMessage                           @"error_message"
#define kTrackingPropertyServerResponseBody                     @"server_response_body"
#define kTrackingPropertyEndpointName                           @"endpoint_name"
#define kTrackingPropertyServerResponse                         @"server_response"

#define kSuggestTagName @"tag_name"

//Auth
#define kKeyChainServiceURL @"flyyapp.com"
#define kAuthTokenKey @"kAuthTokenKey"
#define kLoggedInUserDefaultKey @"kLoggedInUserDefaultKey"
#define kLoggedInUserNsUserDefaultKey @"kLoggedInUserNsUserDefaultKey"

// onboarding
#define kFeedOnboardingKey @"kFeedOnboardingKey"
#define kRecordingOnboardingKey @"kRecordingOnboardingKey"
#define kTopicDetailOnboardingKey @"kTopicDetailOnboardingKey"

// user default
#define kConfigsUserDefaultKey @"kConfigsUserDefaultKey"
#define kDeviceTokenUserDefaultKey @"kDeviceTokenUserDefaultKey"

// One time keys
#define kHasShownEnablePushNotificationDialog @"kHasShownEnablePushNotificationDialog"


#define kPrivacyPolicyURL   @"https://www.flyyapp.com/privacy.html"
#define kTermsOfServiceURL  @"https://www.flyyapp.com/terms.html"
#define kRulesURL  @"https://www.flyyapp.com/rules.html"

#ifdef NDEBUG
    #define NSLog(...) /* suppress NSLog when in release mode */
#endif