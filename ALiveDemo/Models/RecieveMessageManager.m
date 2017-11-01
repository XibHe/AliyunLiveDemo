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
        case 7:
        {
            NSNumber *uid = [dic[@"data"] objectForKey:@"uid"];
            NSString *strUid = [NSString stringWithFormat:@"%d",[uid intValue]];
            NSString *name = [dic[@"data"] objectForKey:@"name"];
            if (self.delegate && [self.delegate respondsToSelector:@selector(onGetLikeMessage:name:)]) {
                [self.delegate onGetLikeMessage:strUid name:name];
            }
        }
            break;
            
        default:
            break;
    }
}
@end
