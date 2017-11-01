//
//  UserInfo.h
//  ALiveDemo
//
//  Created by zyjk_iMac-penghe on 2017/10/26.
//  Copyright © 2017年 zyjk_iMac-penghe. All rights reserved.
//

#import "AlivcRootJSONModel.h"

@interface UserInfo : AlivcRootJSONModel

@property (nonatomic, strong) NSString *id;   // 服务器返回的用户id
@property (nonatomic, strong) NSString *name;
@end
