#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ALIVC_EXTERN     extern __attribute__((visibility ("default")))

ALIVC_EXTERN NSString * const AliVcMediaPlayerLoadDidPreparedNotification;
ALIVC_EXTERN NSString * const AliVcMediaPlayerPlaybackDidFinishNotification;
ALIVC_EXTERN NSString * const AliVcMediaPlayerStartCachingNotification;
ALIVC_EXTERN NSString * const AliVcMediaPlayerEndCachingNotification;
ALIVC_EXTERN NSString * const AliVcMediaPlayerPlaybackErrorNotification;
ALIVC_EXTERN NSString * const AliVcMediaPlayerSeekingDidFinishNotification;
ALIVC_EXTERN NSString * const AliVcMediaPlayerFirstFrameNotification;

/**
 *  播放器错误代码
 *  可以在errorCode中获取到错误代码
 *  在AliVcMediaPlayerPlaybackErrorNotification获取到视频播放的错误代码
 */
enum{
    ALIVC_SUCCESS = 0,                     // 无错误
    
    ALIVC_ERR_ILLEGALSTATUS = -400,         // 非法的播放器状态
    ALIVC_ERR_NO_NETWORK = -401,            // 网络视频播放错误，没有网络或者网络状态不好的情况下播放网络视频会出现该错误
    ALIVC_ERR_FUNCTION_DENIED = -402,       // 授权功能被拒绝，没有经过授权
    
    ALIVC_ERR_UNKOWN = -501,                // 未知错误
    ALIVC_ERR_NO_INPUTFILE = -502,          // 无输入文件，没有设置dataSource
    ALIVC_ERR_NO_VIEW = -503,               // 没有设置显示窗口
    ALIVC_ERR_INVALID_INPUTFILE = -504,     // 无效的输入文件，不是一个有效的视频文件
    ALIVC_ERR_NO_SUPPORT_CODEC = -505,      // 视频编码格式不支持，不支持这种编码格式的播放
    ALIVC_ERR_NO_MEMORY = -506,             // 没有足够的内存
    ALIVC_ERR_DOWNLOAD_TIMEOUT = -507,      // 下载超时
};
typedef NSInteger AliVcMovieErrorCode;

enum {
    MediaType_AUTO = -1,
    MediaType_VOD = 0,
    MediaType_LIVE = 1
};
typedef NSInteger MediaType;

enum {
    scalingModeAspectFit = 0,
    scalingModeAspectFitWithCropping = 1,
};
typedef NSInteger ScalingMode;

@interface AliVcAccesskey : NSObject

@property(atomic,weak)     NSString* accessKeyId;
@property(atomic,weak)     NSString* accessKeySecret;

@end

/**
 * 获取AccessKeyID和AccessKeySecret协议，用户必须实现该协议来完成授权验证
 */
@protocol AliVcAccessKeyProtocol <NSObject>
- (AliVcAccesskey*)getAccessKeyIDSecret;
@end
