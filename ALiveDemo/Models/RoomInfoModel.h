//
//  RoomInfoModel.h
//  ALiveDemo
//
//  Created by zyjk_iMac-penghe on 2017/10/26.
//  Copyright © 2017年 zyjk_iMac-penghe. All rights reserved.
//

#import "AlivcRootJSONModel.h"

@interface RoomInfoModel : AlivcRootJSONModel

@property (nonatomic, strong) NSString *uid;     // 用户id
@property (nonatomic, strong) NSString *name;    // 用户昵称
@property (nonatomic, strong) NSString *m3u8PlayUrl;
@property (nonatomic, strong) NSString *playUrl; // 推流地址 ?
@property (nonatomic, strong) NSString *rtmpPlayUrl;
@property (nonatomic, strong) NSString *rtmpUrl;
@property (nonatomic, strong) NSString *type;    // 类型
@property (nonatomic, strong) NSString *roomId;  // 直播间id
@property (nonatomic, assign) NSInteger status;  // 推流状态
@end
