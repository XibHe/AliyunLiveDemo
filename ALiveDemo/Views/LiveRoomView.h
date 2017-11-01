//
//  LiveRoomView.h
//  ALiveDemo
//
//  Created by zyjk_iMac-penghe on 2017/10/30.
//  Copyright © 2017年 zyjk_iMac-penghe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LiveRoomView;
@protocol LiveRoomViewDelegate <NSObject>
- (void)quitLiveAction;
- (void)likeLiveAction;
- (void)switchCameraAction;
- (void)beautyAction:(UIButton *)sender;
@end

@interface LiveRoomView : UIView

@property (nonatomic, strong) UIView *mediaPalyerView;    // 直播播放视图
@property (nonatomic, assign) id <LiveRoomViewDelegate> delegate;
@end

