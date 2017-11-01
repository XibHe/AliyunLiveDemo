//
//  AlivcVideoChatParter.h
//  AlivcVideoChat
//
//  Copyright © 2017年 Aliyun. All rights reserved.
//


#import <Foundation/Foundation.h> 
#import <UIKit/UIKit.h>
#import "alivcVideoChatParam.h"
#import "alivcPlayerPerformanceInfo.h"
#import "alivcPublisherPerformanceInfo.h"



/**
 观众端
 */
@interface AlivcVideoChatParter : NSObject


/**
 开始观看直播。调用该函数将启动直播播放器，并播放获取到的直播流

 @param url 直播播放地址
 @param view 直播播放器的渲染窗口
 @return 0：正常；非0：错误
 */
- (int)startToPlay:(NSURL*)url view:(UIView*)view;


/**
 设置播放器相关的配置参数

 @param playerParam 播放配置
        * ALIVC_PLAYER_PARAM_DOWNLOADTIMEOUT：	播放器缓冲超时时间，单位ms。默认15000。
        * ALIVC_PLAYER_PARAM_DROPBUFFERDURATION：	播放器开始丢帧阈值，单位ms。连麦过程中默认值为1000，非连麦过程中默认值为8000。
        * ALIVC_PLAYER_PARAM_SCALINGMODE：	播放器显示模式，目前支持2种。枚举成员scalingModeAspectFit = 0，代表等比例缩放，若显示窗口宽高比与视频不同则会有黑边；scalingModeAspectFitWithCropping = 1，代表带切边的等比例缩放，若显示窗口宽高比与视频不同，则自动对视频裁边以撑满显示窗口。 默认值为1。
 */
- (void)setPlayerParam:(NSDictionary*)playerParam;


/**
 当用户遇到网络切换导致流断后，可以调用reconnect函数进行重新连接(多人连麦使用，指定重连某个播放地址)

 @param playerUrl 播放超时的视频的url
 @return 0：正常；非0：错误
 */
- (int)reconnect:(NSURL*)playerUrl;


/**
 结束观看直播。调用该函数将关闭直播播放器，并销毁所有资源(若在连麦状态下调用该函数，则sdk会先停止连麦，再结束播放)

 @return 0：正常；非0：错误
 */
- (int)stopPlaying;


/**
 开始连麦(调用该函数将开启音视频的采集设备、启动预览功能、启动音视频编码功能并将压缩后的音视频流上传。同时将播放地址切换到具备短延时功能的新地址)

 @param publisherUrl 连麦时推流的地址
 @param width 推流视频的宽度
 @param height 推流视频的高度
 @param preview 连麦时推流的预览窗口view
 @param publisherParam ：连麦时推流的参数。使用NSDictionary的方式，以便于后续的扩展
        * ALIVC_PUBLISHER_PARAM_UPLOADTIMEOUT	推流上传超时时间，单位ms,默认15000
        * ALIVC_PUBLISHER_PARAM_CAMERAPOSITION	选择前后摄像头，枚举成员：cameraPositionFront = 0,cameraPositionBack = 1。默认前置。
        * ALIVC_PUBLISHER_PARAM_LANDSCAPE	推流横屏/竖屏，NO为竖屏，YES为竖屏。默认竖屏。
        * ALIVC_PUBLISHER_PARAM_MAXBITRATE	推流最大码率，单位Kbps。默认1500。
        * ALIVC_PUBLISHER_PARAM_MINBITRATE	推流最小码率，单位Kbps。默认200。
        * ALIVC_PUBLISHER_PARAM_ORIGINALBITRATE	推流初始码率，单位Kbps。默认500。
        * ALIVC_PUBLISHER_PARAM_AUDIOSAMPLERATE	推流音频采样率，单位Hz。固定32000，暂不可调。
        * ALIVC_PUBLISHER_PARAM_AUDIOBITRATE	推流音频码率，单位Kbps。固定96，暂不可调。
        * ALIVC_PUBLISHER_PARAM_FRONTCAMERAMIRROR	前置摄像头是否镜像。
 @param playerUrl 连麦时切换到的短延时播放地址
 @return 0：正常；非0：错误
 */
- (int)onlineChat:(NSString*)publisherUrl width:(int)width height:(int)height preview:(UIView*)preview publisherParam:(NSDictionary*)publisherParam playerUrl:(NSURL*)playerUrl;



/**
 开始多人连麦(调用该函数将开启音视频的采集设备、启动预览功能、启动音视频编码功能并将压缩后的音视频流上传。同时将主播和参与连麦的观众的播放地址切换到具备短延时功能的新地址)

 @param publisherUrl 连麦时推流的地址
 @param width 推流视频的宽度
 @param height 推流视频的高度
 @param preview 连麦时推流的预览窗口view
 @param publisherParam 连麦时推流的参数。使用NSDictionary的方式，以便于后续的扩展
        * ALIVC_PUBLISHER_PARAM_UPLOADTIMEOUT	推流上传超时时间，单位ms,默认15000
        * ALIVC_PUBLISHER_PARAM_CAMERAPOSITION	选择前后摄像头，枚举成员：cameraPositionFront = 0,cameraPositionBack = 1。默认前置。
        * ALIVC_PUBLISHER_PARAM_LANDSCAPE	推流横屏/竖屏，NO为竖屏，YES为竖屏。默认竖屏。
        * ALIVC_PUBLISHER_PARAM_MAXBITRATE	推流最大码率，单位Kbps。默认1500。
        * ALIVC_PUBLISHER_PARAM_MINBITRATE	推流最小码率，单位Kbps。默认200。
        * ALIVC_PUBLISHER_PARAM_ORIGINALBITRATE	推流初始码率，单位Kbps。默认500。
        * ALIVC_PUBLISHER_PARAM_AUDIOSAMPLERATE	推流音频采样率，单位Hz。固定32000，暂不可调。
        * ALIVC_PUBLISHER_PARAM_AUDIOBITRATE	推流音频码率，单位Kbps。固定96，暂不可调。
        * ALIVC_PUBLISHER_PARAM_FRONTCAMERAMIRROR	前置摄像头是否镜像。
 @param hostPlayUrl 主播流的播放地址
 @param playerUrls 参与连麦观众的直播流的播放地址
 @param playerViews 参与连麦观众的直播流的播放窗口view
 @return 0：正常；非0：错误
 */
- (int)onlineChats:(NSString*)publisherUrl width:(int)width height:(int)height preview:(UIView*)preview publisherParam:(NSDictionary*)publisherParam hostPlayUrl:(NSURL*)hostPlayUrl playerUrls:(NSArray*)playerUrls playerViews:(NSArray*)playerViews;


/**
 增加连麦人数。在此之前，主播正在当前观众正在连麦。新增的连麦人数可以是一个人，也可以是多个人

 @param playerUrls 参与连麦观众的直播流的播放地址
 @param playerViews 参与连麦观众的直播流的播放窗口view
 @return 0：正常；非0：错误
 */
- (int)addChats:(NSArray*)playerUrls playerViews:(NSArray*)playerViews;


/**
 减少连麦人数。减少的连麦人数可以是一个人，也可以是多个人(必须调用函数onlineChats后才能调用该函数。允许让当前观众退出连麦，此时，调用removeChats与offlineChat功能相同)

 @param playerUrls 所有退出连麦者的播放地址
 @return 0：正常；非0：错误
 */
- (int)removeChats:(NSArray*)playerUrls;


/**
 结束连麦。调用该函数将结束观众的推流，销毁推流的所有资源，并将播放地址切换到连麦之前的地址

 @return 0：正常；非0：错误
 */
- (int)offlineChat;


/**
 获取推流的性能参数值，参考AlivcPublisherPerformanceInfo

 @return 推流性能参数
 */
- (AlivcPublisherPerformanceInfo *)getPublisherPerformanceInfo;


/**
 获取播放的性能参数值，参考AlivcPlayerPerformanceInfo

 @param url 指定播放器的性能参数
 @return 播放性能参数
 */
- (AlivcPlayerPerformanceInfo *)getPlayerPerformanceInfo:(NSURL*)url;



/**
 连麦进入后台暂停，有音频采集，无视频采集，正常播放进入后台有声音播放
 此时进入后台不中断推流，有声音采集，视频数据停在最后一帧。后台采集音频需要在app的Capablities中打开Background Mode选项，选中Audio,AirPlay and Picture in Picture
 */
- (void)pause;


/**
 恢复到前台
 */
- (void)resume;


/**
 切换摄像头

 @return 是否成功
 */
- (int)switchCamera;


/**
 缩放摄像头(仅对后置摄像头有效)

 @param zoom zoom：放大倍率。最小值为1.0，表示不放大；最大值maxZoom与设备本身相关，且上限设置为3.0，即maxZoom = min（maxZoom，3.0)
 @return 是否成功
 */
- (int)zoomCamera:(CGFloat)zoom;


/**
 聚焦到某个设置的点。调用该函数可以聚焦到预览窗口上人为指定的某个点

 @param point 需要聚焦到的点的位置。（0.0，0.0）代表左上角，（1.0，1.0）代表右下角，（0.5，0.5）代表中心点
 @param autoFocus 自动聚焦模式。0代表只自动聚焦一次，以后将按照固定的景深来进行聚焦；1代表持续自动聚焦，当拍摄的物体变换时仍然会自动调整景深来聚焦
 @return 是否成功
 */
- (int)focusCameraAtAdjustedPoint:(CGPoint)point autoFocus:(BOOL)autoFocus;


/**
 设置滤镜参数(目前只包含一个美颜滤镜)

 @param param 滤镜相关的配置参数。使用NSDictionary的方式，以便于后续的扩展
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
 连麦时候推流是否静音
 */
@property (nonatomic, readwrite) BOOL pulisherMuteMode;


@end
