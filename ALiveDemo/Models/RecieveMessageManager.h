//
//  RecieveMessageManager.h
//  ALiveDemo
//
//  Created by zyjk_iMac-penghe on 2017/10/31.
//  Copyright © 2017年 zyjk_iMac-penghe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AlivcLiveChatRoom/AlivcLiveChatRoom.h>

@protocol RecieveMessageDelegate <NSObject>

/**
 请求连麦
 */
@optional
- (void)onGetInviteMessage:(NSString *)inviterUid inviterName:(NSString*)inviterName inviterType:(int)inviterType;

/**
 同意连麦
 */
@optional
- (void)onGetInviteAgreeMessage:(NSString*)inviteeUid inviteeName:(NSString*)inviteeName inviteeRoomId:(NSString*)inviteeRoomId inviterRoomId:(NSString*)inviterRoomId mainPlayUrl:(NSURL*)mainPlayUrl rtmpUrl:(NSString*)rtmpUrl otherPlayUrls:(NSArray*)otherPlayUrls otherPlayUids:(NSArray*)otherPlayUids;

// 点赞
@optional
- (void)onGetLikeMessage:(NSString*)uid name:(NSString*)name;


@end

@interface RecieveMessageManager : NSObject <AlivcLiveClientReceiveMessageDelegate>
@property (nonatomic, assign) id <RecieveMessageDelegate> delegate;
@end
