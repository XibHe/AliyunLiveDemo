//
//  LiveInviteInfo.h
//  DemoAlivcLive
//
//  发起连麦人的信息model
//
//  Created by LYZ on 17/1/6.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveInviteInfo : NSObject

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *playUrl;

+ (LiveInviteInfo *)liveWithUid:(NSString *)uid roomId:(NSString *)roomId name:(NSString *)name playUrl:(NSString*)playUrl;

@end
