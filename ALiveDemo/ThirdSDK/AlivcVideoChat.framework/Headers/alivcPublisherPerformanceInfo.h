//
//  AlivcPublisherPerformanceInfo.h
//  AlivcVideoChat
//
//  Copyright © 2017年 Aliyun. All rights reserved.
//


#import <Foundation/Foundation.h> 
#import <UIKit/UIKit.h>


/**
 推流性能参数
 */
@interface AlivcPublisherPerformanceInfo : NSObject


/**
 音频编码码率
 */
@property (nonatomic, assign) int audioEncodedBitrate;


/**
 视频编码码率
 */
@property (nonatomic, assign) int videoEncodedBitrate;


/**
 音频上传码率
 */
@property (nonatomic, assign) int audioUploadedBitrate;


/**
 视频上传码率
 */
@property (nonatomic, assign) int videoUploadedBitrate;


/**
 音频buffer个数
 */
@property (nonatomic, assign) int audioPacketsInBuffer;


/**
 视频buffer个数
 */
@property (nonatomic, assign) int videoPacketsInBuffer;


/**
 视频编码FPS
 */
@property (nonatomic, assign) int videoEncodedFps;


/**
 视频上传FPS
 */
@property (nonatomic, assign) int videoUploadedFps;


/**
 视频采集FPS
 */
@property (nonatomic, assign) int videoCaptureFps;


/**
 视频编码码率
 */
@property (nonatomic, assign) int videoEncoderParamOfBitrate;


/**
 当前上传视频帧PTS
 */
@property (nonatomic, assign) uint64_t currentlyUploadedVideoFramePts;


/**
 当前上传音频帧PTS
 */
@property (nonatomic, assign) uint64_t currentlyUploadedAudioFramePts;


/**
 当前上传关键帧PTS
 */
@property (nonatomic, assign) uint64_t previousKeyframePts;


/**
 视频编码总帧数
 */
@property (nonatomic, assign) uint64_t totalFramesOfEncodedVideo;


/**
 视频编码总耗时
 */
@property (nonatomic, assign) uint64_t totalTimeOfEncodedVideo;


/**
 数据上传总大小
 */
@property (nonatomic, assign) uint64_t totalSizeOfUploadedPackets;


/**
 视频推流总耗时
 */
@property (nonatomic, assign) uint64_t totalTimeOfPublishing;


/**
 视频上传总帧数
 */
@property (nonatomic, assign) uint64_t totalFramesOfVideoUploaded;


/**
 视频丢帧总数
 */
@property (nonatomic, assign) uint64_t dropDurationOfVideoFrames;


/**
 音频从采集到上传耗时
 */
@property (nonatomic, assign) uint64_t audioDurationFromCaptureToUpload;


/**
 视频从采集到上传耗时
 */
@property (nonatomic, assign) uint64_t videoDurationFromCaptureToUpload;

@end
