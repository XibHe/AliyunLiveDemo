//
//  LiveRoomViewController.h
//  ALiveDemo
//
//  直播间
//
//  Created by zyjk_iMac-penghe on 2017/10/30.
//  Copyright © 2017年 zyjk_iMac-penghe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveRoomViewController : UIViewController

@property (nonatomic, copy) NSString *userUid;
@property (nonatomic, copy) NSString *playUrl;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *hostUid;
@property (nonatomic, copy) NSString *liveName;

@end
