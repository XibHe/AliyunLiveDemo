//
//  AlivcVideoChatHost.h
//  AlivcVideoChat
//
//  Copyright © 2017年 Aliyun. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "alivcVideoChatParam.h"
#import "alivcPublisherPerformanceInfo.h"
#import "alivcPlayerPerformanceInfo.h"



/**
 主播端
 */
@interface AlivcVideoChatHost : NSObject

/**
 准备推流，建立预览画面

 @param view 推流预览窗口
 @param width 推流宽度
 @param height 推流高度
 @param publisherParam 推流配置：
        * ALIVC_PUBLISHER_PARAM_UPLOADTIMEOUT： 推流上传超时时间，单位ms,默认15000。
        * ALIVC_PUBLISHER_PARAM_CAMERAPOSITION： 选择前后摄像头，枚举成员： cameraPositionFront = 0, cameraPositionBack = 1。默认前置。
        * ALIVC_PUBLISHER_PARAM_LANDSCAPE：推流横屏/竖屏，NO为竖屏，YES为竖竖。默认竖屏。
        * ALIVC_PUBLISHER_PARAM_MAXBITRATE：推流最大码率，单位Kbps。默认1500。
        * ALIVC_PUBLISHER_PARAM_MINBITRATE：推流最小码率，单位Kbps。默认200。
        * ALIVC_PUBLISHER_PARAM_ORIGINALBITRATE： 推流初始码率，单位Kbps。默认500。
        * ALIVC_PUBLISHER_PARAM_AUDIOSAMPLERATE： 推流音频采样率，单位Hz。固定32000，暂不可调。
        * ALIVC_PUBLISHER_PARAM_AUDIOBITRATE： 推流音频码率，单位Kbps。固定96，暂不可调。
        * ALIVC_PUBLISHER_PARAM_FRONTCAMERAMIRROR： 前置摄像头是否镜像。
 @return 0：正常；非0：错误
 */
- (int)prepareToPublish:(UIView*)view width:(int)width height:(int)height publisherParam:(NSDictionary*)publisherParam;


/**
 准备推流

 @param url 推流地址
 @return 0：正常；非0：错误
 */
- (int)startToPublish: (NSString*)url;


/**
 停止推流

 @return 0：正常；非0：错误
 */
- (int)stopPublishing;


/**
 停止预览

 @return 0：正常；非0：错误
 */
- (int)finishPublishing;


/**
 设置连麦时候的播放器参数

 @param playerParam 配置参数
        * ALIVC_PLAYER_PARAM_DOWNLOADTIMEOUT： 连麦播放缓冲超时时间，单位ms。默认15000。
        * ALIVC_PLAYER_PARAM_DROPBUFFERDURATION： 连麦播放开始丢帧阈值，单位ms。默认1000。
        * ALIVC_PLAYER_PARAM_SCALINGMODE： 连麦播放显示模式，目前支持2种。枚举成员scalingModeAspectFit = 0，代表等比例缩放，若显示窗口宽高比与视频不同则会有黑边；scalingModeAspectFitWithCropping = 1，代表带切边的等比例缩放，若显示窗口宽高比与视频不同，则自动对视频裁边以撑满显示窗口。 默认值为1。
 */
- (void)setPlayerParam:(NSDictionary*)playerParam;


/**
 动态设置推流配置参数

 @param publisherParam 配置参数
        * ALIVC_PUBLISHER_PARAM_MAXBITRATE：推流最大码率，单位Kbps。
        * ALIVC_PUBLISHER_PARAM_MINBITRATE：推流最小码率，单位Kbps
        * ALIVC_PUBLISHER_PARAM_FRONTCAMERAMIRROR： 前置摄像头是否镜像。

 */
- (void)setPublisherParam:(NSDictionary*)publisherParam;


/**
 开始连麦

 @param url 播放URL
 @param view 播放窗口view
 @return 0：正常；非0：错误
 */
- (int)launchChat:(NSURL*)url view:(UIView*)view;


/**
 开始多人连麦

 @param urls 播放URL数组，NSURL类型
 @param views 播放窗口view数组，UIView类型
 @return 0：正常；非0：错误
 */
- (int)launchChats:(NSArray *)urls views:(NSArray *)views;


/**
 多人加入连麦

 @param urls 播放URL数组，NSURL类型
 @param views 播放窗口数组，UIView类型
 @return 0：正常；非0：错误
 */
- (int)addChats:(NSArray *)urls views:(NSArray *)views;


/**
 移除多人连麦

 @param urls 播放URL数组，NSURL类型
 @return 0：正常；非0：错误
 */
- (int)removeChats:(NSArray *)urls;


/**
 当连麦时，某个连麦者的视频播放超时，调用reconnectChat进行重新打开

 @param url 播放超时的视频的URL
 @return 0：正常；非0：错误
 */
- (int)reconnectChat:(NSURL *)url;


/**
 结束连麦

 @return 0：正常；非0：错误
 */
- (int)abortChat;


/**
 后台暂停，没有视频有音频
 */
- (void)pause;


/**
 恢复到前台

 */
- (void)resume;


/**
 在推流过程中切换前后摄像头

 @return 是否成功
 */
- (int)switchCamera;


/**
 缩放摄像头(仅对后置摄像头有效)

 @param zoom 放大倍率 最小值为1.0，表示不放大；最大值maxZoom与设备本身相关，且上限设置为3.0，即maxZoom = min（maxZoom，3.0）
 @return 是否缩放成功
 */
- (int)zoomCamera:(CGFloat)zoom;


/**
 聚焦到某个设置的点。调用该函数可以聚焦到预览窗口上人为指定的某个点

 @param point 需要聚焦到的点的位置。（0.0，0.0）代表左上角，（1.0，1.0）代表右下角，（0.5，0.5）代表中心点
 @param autoFocus 自动聚焦模式。0代表只自动聚焦一次，以后将按照固定的景深来进行聚焦；1代表持续自动聚焦，当拍摄的物体变换时仍然会自动调整景深来聚焦
 @return 是否聚焦成功
 */
- (int)focusCameraAtAdjustedPoint:(CGPoint)point autoFocus:(BOOL)autoFocus;


/**
 设置滤镜参数(目前只包含一个美颜滤镜)

 @param param 滤镜参数
        * ALIVC_FILTER_PARAM_BEAUTY_ON：美颜是否开启
        * ALIVC_FILTER_PARAM_BEAUTY_WHITEN：美白程度[0,100]
        * ALIVC_FILTER_PARAM_BEAUTY_BUFFING：磨皮程度[0,35]
        * ALIVC_FILTER_PARAM_BEAUTY_SLIM：瘦脸程度[-1,1]
        * ALIVC_FILTER_PARAM_BEAUTY_FACEREDDEN：粉嫩程度[0,40]
 */
- (void)setFilterParam:(NSDictionary*)param;


/**
 获取SDK版本号(当开发者反馈问题时，请使用该方法获得SDK版本号并随同问题一起反馈)

 @return NSString类型的版本号
 */
- (NSString *)getSDKVersion;


/**
 获取推流的性能参数值，参考AlivcPublisherPerformanceInfo

 @return 推流性能参数
 */
- (AlivcPublisherPerformanceInfo *)getPublisherPerformanceInfo;


/**
 获取播放的性能参数值，参考AlivcPlayerPerformanceInfo

 @param url 指定播放器的性能参数
 @return 播放器性能参数
 */
- (AlivcPlayerPerformanceInfo *)getPlayerPerformanceInfo:(NSURL*)url;


/**
 是否静音
 */
@property (nonatomic, readwrite) BOOL publisherMuteMode;


@end
