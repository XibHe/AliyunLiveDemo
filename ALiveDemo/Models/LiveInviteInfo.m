//
//  LiveInviteInfo.m
//  DemoAlivcLive
//
//  Created by LYZ on 17/1/6.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import "LiveInviteInfo.h"

@implementation LiveInviteInfo

+ (LiveInviteInfo *)liveWithUid:(NSString *)uid roomId:(NSString *)roomId name:(NSString *)name playUrl:(NSString *)playUrl
{
    LiveInviteInfo *info = [[LiveInviteInfo alloc] init];
    info.uid = uid;
    info.roomId = roomId;
    info.playUrl = playUrl;
    info.name = name;
    return info;
}

// 未定义的key值，避免崩溃
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
}
@end
