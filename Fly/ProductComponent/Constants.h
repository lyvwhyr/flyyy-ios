
#include "FLYNotificationConstant.h"

#define kStatusBarHeight    20
#define kNavBarHeight       44
#define kTabBarViewHeight   44
#define kTopicPaginationCount 15
#define KReplyPaginationCount 15

#define kMainScreenWidth      CGRectGetWidth([UIScreen mainScreen].bounds)
#define kMainScreenHeight     CGRectGetHeight([UIScreen mainScreen].bounds)
#define kContainerViewHeight  kMainScreenHeight - kStatusBarHeight - kNavBarHeight - kTabBarViewHeight

#define kNewPostKey @"kNewPostKey"
#define kNewReplyKey @"kNewReplyKey"
#define kDownloadAudioLocalPathkey @"kDownloadAudioLocalPathkey"
#define kDownloadAudioTypeKey @"kDownloadAudioTypeKey"

#define kAudioCacheFolder   @"flyyapp.com.audios"



//Mixpanel event
#define kTrackingEventClientError                               @"client_error"


//Mixpanel properties
#define kTrackingPropertyStatusCode                             @"status_code"
#define kTrackingPropertyErrorMessage                           @"error_message"
#define kTrackingPropertyServerResponseBody                     @"server_response_body"