//
//  RecieveMessageManager.m
//  ALiveDemo
//
//  Created by zyjk_iMac-penghe on 2017/10/31.
//  Copyright © 2017年 zyjk_iMac-penghe. All rights reserved.
//

#import "RecieveMessageManager.h"

@implementation RecieveMessageManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        //self.delegate = nil;
        [[AlivcLiveClient shareClient] setAlivcLiveClientReceiveMessageDelegate:self];
    }
    return self;
}

- (void)onReceivedChatMessage:(NSString *)message
{
    NSLog(@"收到消息 txt -- %@",message);
    NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        NSLog(@"主播端推送信息JSON解析失败");
        return;
    }
    
    NSInteger type = [[dic objectForKey:@"type"] integerValue];
    switch (type) {
        case 1:
        {
            int nInviterType = 1;
            NSString *inviterUid = [dic[@"data"] objectForKey:@"inviterUid"];
            NSString* strInviterUid = [NSString stringWithFormat:@"%d",[inviterUid intValue]];
            NSString *inviterName = [dic[@"data"] objectForKey:@"inviterName"];
            NSString *inviterType = [dic[@"data"] objectForKey:@"inviterType"];
            
            if (inviterType) {
                nInviterType = [inviterType intValue];
            }
            // 请求连麦
            if (self.delegate&& [self.delegate respondsToSelector:@selector(onGetInviteMessage:inviterName:inviterType:)]) {
                [self.delegate onGetInviteMessage:strInviterUid inviterName:inviterName inviterType:nInviterType];
            }
        }
            break;
        case 2:
        {
            NSString *inviterUid = [dic[@"data"] objectForKey:@"inviteeUid"];
            NSString* strInviterUid = [NSString stringWithFormat:@"%d",[inviterUid intValue]];
            NSString *inviteeName = [dic[@"data"] objectForKey:@"inviteeName"];
            NSString *inviteeRoomId = [dic[@"data"] objectForKey:@"inviteeRoomId"];
            NSString *inviterRoomId = [dic[@"data"] objectForKey:@"inviterRoomId"];
            NSString *mainPlayUrl = [dic[@"data"] objectForKey:@"mainPlayUrl"];
            NSString *rtmpUrl = [dic[@"data"] objectForKey:@"rtmpUrl"];
            NSURL* playUrl = [NSURL URLWithString:mainPlayUrl];
            NSArray* playUrls = [dic[@"data"] objectForKey:@"playUrls"];
            
            NSMutableArray<NSURL*>* playArrays = [[NSMutableArray alloc] init];
            NSMutableArray<NSString*>* playUidArrays = [[NSMutableArray alloc] init];
            
            for (NSDictionary* playDic in playUrls) {
                [playArrays addObject:[NSURL URLWithString:[playDic objectForKey:@"url"]]];
                
                NSString *strUid = [NSString stringWithFormat:@"%d",[[playDic objectForKey:@"uid"] intValue]];
                [playUidArrays addObject:strUid];
            }
            // 同意连麦
            if (self.delegate && [self.delegate respondsToSelector:@selector(onGetInviteAgreeMessage:inviteeName:inviteeRoomId:inviterRoomId:mainPlayUrl:rtmpUrl:otherPlayUrls:otherPlayUids:)]) {
                [self.delegate onGetInviteAgreeMessage:strInviterUid inviteeName:inviteeName inviteeRoomId:inviteeRoomId inviterRoomId:inviterRoomId mainPlayUrl:playUrl rtmpUrl:rtmpUrl otherPlayUrls:playArrays otherPlayUids:playUidArrays];
            }
        }
            break;
        case 7:
        {
            NSNumber *uid = [dic[@"data"] objectForKey:@"uid"];
            NSString *strUid = [NSString stringWithFormat:@"%d",[uid intValue]];
            NSString *name = [dic[@"data"] objectForKey:@"name"];
            // 点赞
            if (self.delegate && [self.delegate respondsToSelector:@selector(onGetLikeMessage:name:)]) {
                [self.delegate onGetLikeMessage:strUid name:name];
            }
        }
            break;
        case 9:
        {
            NSString *roomId = [dic[@"data"] objectForKey:@"roomId"];
            NSNumber *uid = [dic[@"data"] objectForKey:@"uid"];
            NSString *strUid = [NSString stringWithFormat:@"%d",[uid intValue]];
            NSString *name = [dic[@"data"] objectForKey:@"name"];
            NSString *playUrl = [dic[@"data"] objectForKey:@"playUrl"];
            // 开始推流
            if (self.delegate && [self.delegate respondsToSelector:@selector(onGetStartLiveMessage:uid:name:playUrl:)]) {
                [self.delegate onGetStartLiveMessage:roomId uid:strUid name:name playUrl:playUrl];
            }
        }
            break;
        case 19:
        {
            LiveInviteInfo *info = [[LiveInviteInfo alloc] init];
            [info setValuesForKeysWithDictionary:dic[@"data"]];
            // 断开连麦
            if (self.delegate && [self.delegate respondsToSelector:@selector(onGetLeaveVideoChatMessage:)]) {
                [self.delegate onGetLeaveVideoChatMessage:info];
            }
        }
            break;
        default:
            break;
    }
}
@end
