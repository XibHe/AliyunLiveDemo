

#define ALIVC_EXTERN     extern __attribute__((visibility ("default")))

/**
 通知定义
 */
ALIVC_EXTERN NSString * const AlivcVideoChatPublisherOpenFailed;
ALIVC_EXTERN NSString * const AlivcVideoChatPublisherSendDataTimeout;
ALIVC_EXTERN NSString * const AlivcVideoChatPublisherNetSpeedPoor;
ALIVC_EXTERN NSString * const AlivcVideoChatPublisherCaptureFpsSlow;
ALIVC_EXTERN NSString * const AlivcVideoChatPublisherVideoCaptureDisabled;
ALIVC_EXTERN NSString * const AlivcVideoChatPublisherAudioCaptureDisabled;
ALIVC_EXTERN NSString * const AlivcVideoChatPublisherAudioCaptureError;
ALIVC_EXTERN NSString * const AlivcVideoChatPublisherVideoEncoderInitFailed;
ALIVC_EXTERN NSString * const AlivcVideoChatPublisherAudioEncoderInitFailed;
ALIVC_EXTERN NSString * const AlivcVideoChatMemoryPool;
ALIVC_EXTERN NSString * const AlivcVideoChatPublisherEncodeVideoFailed;
ALIVC_EXTERN NSString * const AlivcVideoChatPublisherEncodeAudioFailed;
ALIVC_EXTERN NSString * const AlivcVideoChatPlayerOpenFailed;
ALIVC_EXTERN NSString * const AlivcVideoChatPlayerStartBuffering;
ALIVC_EXTERN NSString * const AlivcVideoChatPlayerEndBuffering;
ALIVC_EXTERN NSString * const AlivcVideoChatPlayerFirstFrameRender;
ALIVC_EXTERN NSString * const AlivcVideoChatPlayerReadPacketTimeout;
ALIVC_EXTERN NSString * const AlivcVideoChatPlayerNoDisplayViewer;
ALIVC_EXTERN NSString * const AlivcVideoChatPlayerInvalidCodec;

// 打开美颜
#define ALIVC_FILTER_PARAM_BEAUTY_ON @"alivc_filter_param_beauty_on"

// 美白参数 0-100
#define ALIVC_FILTER_PARAM_BEAUTY_WHITEN @"alivc_filter_param_beauty_whiten"

// 磨皮参数，0-35
#define ALIVC_FILTER_PARAM_BEAUTY_BUFFING @"alivc_filter_param_beauty_buffing"

// 瘦脸参数 -1.0-1.0
#define ALIVC_FILTER_PARAM_BEAUTY_SLIM @"alivc_filter_param_beauty_slim"

//粉嫩参数  0-40
#define ALIVC_FILTER_PARAM_BEAUTY_FACEREDDEN @"alivc_filter_param_beauty_faceRedden"


/**
 LiveParam定义
 */
#define ALIVC_PUBLISHER_PARAM_UPLOADTIMEOUT      @"alivc_publisher_param_uploadTimeout"
#define ALIVC_PUBLISHER_PARAM_CAMERAPOSITION     @"alivc_publisher_param_cameraPosition"
#define ALIVC_PUBLISHER_PARAM_LANDSCAPE          @"alivc_publisher_param_landscape"
#define ALIVC_PUBLISHER_PARAM_MAXBITRATE         @"alivc_publisher_param_maxBitrate"
#define ALIVC_PUBLISHER_PARAM_MINBITRATE         @"alivc_publisher_param_minBitrate"
#define ALIVC_PUBLISHER_PARAM_ORIGINALBITRATE    @"alivc_publisher_param_originalBitrate"
#define ALIVC_PUBLISHER_PARAM_AUDIOSAMPLERATE    @"alivc_publisher_param_audioSampleRate"
#define ALIVC_PUBLISHER_PARAM_AUDIOBITRATE       @"alivc_publisher_param_audioBitrate"
#define ALIVC_PUBLISHER_PARAM_FRONTCAMERAMIRROR  @"alivc_publisher_param_frontCameraMirror"

/**
 playerParam定义
 */
#define ALIVC_PLAYER_PARAM_DOWNLOADIMEOUT         @"alivc_player_param_downloadTimeout"
#define ALIVC_PLAYER_PARAM_DROPBUFFERDURATION     @"alivc_player_param_dropBufferDuration"
#define ALIVC_PLAYER_PARAM_SCALINGMODE            @"alivc_player_param_scalingMode"


/**
 摄像头位置
 */
enum {
    cameraPositionFront = 0,
    cameraPositionBack = 1,
};
