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
// 点赞
- (void)onGetLikeMessage:(NSString*)uid name:(NSString*)name;
@end

@interface RecieveMessageManager : NSObject <AlivcLiveClientReceiveMessageDelegate>
@property (nonatomic, assign) id <RecieveMessageDelegate> delegate;
@end
