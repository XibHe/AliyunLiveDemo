//
//  AlivcLiveClient.h
//  AlivcLiveChatRoom
//
//  Created by LYZ on 16/9/21.
//  Copyright © 2016年 Alivc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlivcLiveChatStatusDefine.h"

@class AlivcWebSocketInfoModel;
@class AlivcLiveChatMessage;

#pragma mark - 消息接收监听器
@protocol AlivcLiveClientReceiveMessageDelegate <NSObject>

- (void)onReceivedChatMessage:(NSString *)message;

@end

#pragma mark - 连接状态监听器
@protocol AlivcLiveConnectionStatusChangeDelegate <NSObject>

- (void)onConnectionStatusChanged:(AlivcLiveConnectionStatus)status;

@end


@interface AlivcLiveClient : NSObject

#pragma mark - 核心类方法
+ (instancetype)shareClient;


#pragma mark - 聊天室操作

- (void)joinChatRoomWithWebSocketInfoModel:(AlivcWebSocketInfoModel *)model
                                   success:(void (^)())successBlock
                                     error:(void (^)(NSError *error))errorBlock;

- (void)quitChatRoomSuccess:(void (^)())successBlock
                      error:(void (^)(NSError *error))errorBlock;



- (void)createChatRoomWithName:(NSString *)chatRoomName
                       success:(void(^)())successBlock
                         error:(void (^)(NSError *error))errorBlock
__deprecated_msg("暂未开放,请勿使用,参考Demo与appServer交互");


- (AlivcLiveChatMessage *)sendMessage:(AlivcLiveConversationType)conversationType
                              content:(NSString *)content
                              success:(void (^)(long messageId))successBlock
                                error:(void (^)(NSError *error, long messageId))errorBlock
__deprecated_msg("暂未开放,请勿使用,参考Demo与appServer交互");

#pragma mark - 消息接受监听
- (void)setAlivcLiveClientReceiveMessageDelegate:(id<AlivcLiveClientReceiveMessageDelegate>)delegate;

#pragma mark - 连接状态监听
- (void)setAlivcLiveConnectionStatusChangeDelegate:(id<AlivcLiveConnectionStatusChangeDelegate>)delegate;

@end
