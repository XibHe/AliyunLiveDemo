//
//  AlivcPlayerPerformanceInfo.h
//  AlivcVideoChat
//
//  Copyright © 2017年 Aliyun. All rights reserved.
//


#import <Foundation/Foundation.h> 
#import <UIKit/UIKit.h>



/**
 播放器性能参数
 */
@interface AlivcPlayerPerformanceInfo : NSObject


/**
 视频buffer个数
 */
@property (nonatomic, assign) int videoPacketsInBuffer;


/**
 音频buffer个数
 */
@property (nonatomic, assign) int audioPacketsInBuffer;


/**
 视频从下载到渲染耗时
 */
@property (nonatomic, assign) int videoDurationFromDownloadToRender;


/**
 音频从下载到渲染耗时
 */
@property (nonatomic, assign) int audioDurationFromDownloadToRender;


/**
 最后一帧视频PTS
 */
@property (nonatomic, assign) int64_t videoPtsOfLastPacketInBuffer;


/**
 最后一帧音频PTS
 */
@property (nonatomic, assign) int64_t audioPtsOfLastPacketInBuffer;


/**
 视频下载速度
 */
@property (nonatomic, assign) int packetDownloadSpeed;



@end
