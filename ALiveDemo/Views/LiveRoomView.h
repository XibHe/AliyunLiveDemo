//
//  LiveRoomView.h
//  ALiveDemo
//
//  Created by zyjk_iMac-penghe on 2017/10/30.
//  Copyright © 2017年 zyjk_iMac-penghe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "chatView.h"

@class LiveRoomView;
@protocol LiveRoomViewDelegate <NSObject>
@optional
- (void)quitLiveAction;
- (void)connectAction:(UIButton *)sender;
- (void)likeLiveAction;
- (void)switchCameraAction;
- (void)beautyAction:(UIButton *)sender;
- (void)liveRoomViewControllerSwitchFrame:(NSString *)status;
@required
// 断开连麦(观众自己)
- (void)interruptLiveCall;
@end

@interface LiveRoomView : UIView<ChatViewCloseDelegate>

@property (nonatomic, strong) UIView *mediaPalyerView;    // 直播播放视图
@property (nonatomic, assign) id <LiveRoomViewDelegate> delegate;
@property (nonatomic, strong) ChatView *pushView;
@property (nonatomic, strong) UITextView *textView;

/**
 添加多个连麦对话框
 */
- (NSArray<UIView *> *)addChatViewsWithArray:(NSArray*)playArray uidArrays:(NSArray*)uidsArray;
/**
 移除某一个连麦对话框
 */
- (void)removeChatViewsWithUrl:(NSString*)playUrl;
/**
 移除所有连麦对话框
 */
- (void)removeAllChatViews;
@end

