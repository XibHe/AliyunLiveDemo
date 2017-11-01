//
//  SendMessageManager.h
//  ALiveDemo
//
//  发起有直播相关请求的的请求管理类
//
//  Created by zyjk_iMac-penghe on 2017/10/26.
//  Copyright © 2017年 zyjk_iMac-penghe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoomInfoModel.h"
#import "MNSInfoModel.h"
#import "UserInfo.h"
#import <AlivcLiveChatRoom/AlivcLiveChatRoom.h>

@interface SendMessageManager : NSObject


/**
 用户登录
 */
+ (void)userLogIn:(NSString*)userName block:(void (^)(UserInfo* userInfo, NSError *error))block;


/**
 直播列表
 */
+ (void)getAppLiveList:(void (^)(NSMutableArray<RoomInfoModel *>* roomInfos,NSError *error))block;

/**
 创建直播请求
 */
+ (void)creatLive:(NSString*)uid description:(NSString*)description block:(void (^)(RoomInfoModel* roomInfo, MNSInfoModel* mnsInfo, NSError *error))block;

/**
 获取MnsTopicInfo
 */
+ (void)getMnsTopicInfo:(NSString*)topic tags:(NSArray*)tags block:(void (^)(AlivcWebSocketInfoModel *infoModel,NSError *error))block;


/**
 加入直播间成功
 */
+ (void)joinChatRoomWithWebSocketInfoModel:(AlivcWebSocketInfoModel *)model success:(void (^)(void))successBlock error:(void (^)(NSError *error))errorBlock;

/**
 退出直播请求
 */
+ (void)leaveLive:(NSString*)roomId block:(void (^)(NSError *error))block;

#pragma mark - ======== 主播端与观众端分割 ========

/**
 发送加入直播请求
 */
+ (void)watchLive:(NSString*)uid roomId:(NSString*)roomId block:(void (^)(MNSInfoModel* mnsInfo, NSError *error))block;


/**
 退出直播间的请求
 */
+ (void)leaveWatch:(NSString*)roomId uid:(NSString*)uid block:(void (^)(NSError *error))block;

/**
 发送点赞请求
 */
+ (void)likeWatch:(NSString*)uid roomId:(NSString*)roomId block:(void (^)(NSError *error))block;

/**
 退出聊天室
 */
+ (void)quitChatRoomSuccess:(void (^)(void))successBlock error:(void (^)(NSError *error))errorBlock;


#pragma mark - ======== 连麦相关 ========

/**
 发起连麦请求
 */
+ (void)inviteVideoCall:(NSString*)roomId inviterUid:(NSString*)inviterUid inviteeUids:(NSArray<NSString*>*)inviteeUids inviterType:(int)inviterType block:(void (^)(NSError *error))block;

/**
 发起结束连麦请求
 */
+ (void)leaveVideoCall:(NSString*)roomId uid:(NSString*)uid block:(void (^)(NSError *error))block;

/**
 发送获取连麦消息
 @param inviterUid 邀请连麦ID
 @param inviteeUid 被邀请连麦ID
 @param status 是否同意状态 #1同意 2 不同意
 @param inviterType 邀请是否为观众 #1是观众 2 主播
 @param inviteeType 被邀请是否为观众 #1是观众 2 主播
 */
+(void)sendVideoCallFeedBack:(NSString*)inviterUid inviteeUid:(NSString*)inviteeUid status:(int)status inviterType:(int)inviterType inviteeType:(int)inviteeType block:(void (^)(NSURL* mainPlayUrl,NSArray<NSURL*>* playUrls,NSArray<NSString*>* Uids,NSString* rtmpUrl,NSError *error))block;

@end
