//
//  AlivcLiveChatStatusDefine.h
//  AlivcLiveChatRoom
//
//  Created by LYZ on 16/9/21.
//  Copyright © 2016年 Alivc. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark AlivcLiveConversationType - 会话类型
/*!
 会话类型
 */
typedef NS_ENUM(NSUInteger, AlivcLiveConversationType) {
    /*!
     单聊
     */
    ALIVC_CONVERSATION_TYPE_PRIVATE = 1,
    
    /*!
     讨论组
     */
    ALIVC_CONVERSATION_TYPE_DISCUSSION = 2,
};

#pragma mark AlivcLiveErrorCode - 具体业务错误码
typedef NS_ENUM(NSInteger, AlivcLiveConnectionStatus) {
    AlivcLiveConnectionStatusOpen           = 1,  // 与服务器连接成功
    AlivcLiveConnectionStatusClose          = 2,  // 与服务器断开连接
    AlivcLiveConnectionStatusLogin          = 3,  // 已登录
    AlivcLiveConnectionStatusLogOffByServer = 4,  // 已下线
    AlivcLiveConnectionStatusLogOffByUser   = 5   // 用户自己下线
};


