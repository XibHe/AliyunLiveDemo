//
//  StartLiveView.h
//  ALiveDemo
//
//  Created by zyjk_iMac-penghe on 2017/10/28.
//  Copyright © 2017年 zyjk_iMac-penghe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "chatView.h"

@class StartLiveView;
@protocol StartLiveViewDelegate <NSObject>
- (void)quitLiveAction;
- (void)switchCameraAction;
- (void)beautyAction:(UIButton *)sender;
@required
// 主播端断开连麦的观众
- (void)interruptLiveCallWithUrl:(NSString *)playUrl;
@end

@interface StartLiveView : UIView
@property (nonatomic, strong) UIView   *publisherView;    // 直播预览视图
@property (nonatomic, assign) id <StartLiveViewDelegate> delegate;

// 添加连麦窗口
- (NSArray<UIView *> *)addChatViewsWithArray:(NSArray*)playArray uids:(NSArray*)uids;
// 移除连麦窗口，改变窗口位置
- (void)removeChatViewsWithUrl:(NSString*)playUrl;
// 移除所有连麦窗口
- (void)removeAllChatViews;

@end
