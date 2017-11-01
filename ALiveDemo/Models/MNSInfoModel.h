//
//  MNSInfoModel.h
//  ALiveDemo
//
//  MNS消息服务返回model
//
//  Created by zyjk_iMac-penghe on 2017/10/26.
//  Copyright © 2017年 zyjk_iMac-penghe. All rights reserved.
//

#import "AlivcRootJSONModel.h"

@interface MNSInfoModel : AlivcRootJSONModel

@property (nonatomic, strong) NSString *topic;
@property (nonatomic, strong) NSString *roomTag;
@property (nonatomic, strong) NSString *topicLocation;
@property (nonatomic, strong) NSString *userRoomTag;

@end
