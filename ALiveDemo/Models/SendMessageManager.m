//
//  SendMessageManager.m
//  ALiveDemo
//
//  Created by zyjk_iMac-penghe on 2017/10/26.
//  Copyright © 2017年 zyjk_iMac-penghe. All rights reserved.
//

#import "SendMessageManager.h"
#import "AlivcRequestManager.h"

@implementation SendMessageManager

/**
 用户登录
 */
+ (void)userLogIn:(NSString*)userName block:(void (^)(UserInfo* userInfo, NSError *error))block
{
    NSDictionary *param = @{@"name":userName};
    [[AlivcRequestManager manager] requestWithHost:@"login" param:param block:^(NSDictionary *response, NSError *error) {
        
        if (error) {
            if(block)
                block(nil,error);
            return ;
        };
        
        UserInfo* userInfo = [[UserInfo alloc] initWithDictionary:response error:nil];
        
        if(block)
            block(userInfo,error);
    }];
}
/**
 直播列表
 */
+ (void)getAppLiveList:(void (^)(NSMutableArray<RoomInfoModel *>* roomInfos,NSError *error))block
{
    [[AlivcRequestManager manager] requestWithHost:@"live/list" param:nil block:^(NSDictionary *response, NSError *error) {
        if (error) {
            if(block)
                block(nil,error);
            return ;
        };
        NSMutableArray* array = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in response) {
            RoomInfoModel *model = [[RoomInfoModel alloc] initWithDictionary:dictionary error:nil];
            [array addObject:model];
        }
        
        if(block)
            block(array,error);
    }];
}

/**
 创建直播请求
 */
+ (void)creatLive:(NSString*)uid description:(NSString*)description block:(void (^)(RoomInfoModel* roomInfo, MNSInfoModel* mnsInfo, NSError *error))block
{
    NSDictionary *param = @{@"uid":uid,
                            @"desc":description
                            };
    [[AlivcRequestManager manager] requestWithHost:@"live/create" param:param block:^(NSDictionary *response, NSError *error) {
        if (error) {
            if(block)
                block(nil,nil,error);
            return ;
        };
        RoomInfoModel* roomModel = [[RoomInfoModel alloc] initWithDictionary:response error:nil];
        MNSInfoModel* mnsModel = [[MNSInfoModel alloc] initWithDictionary:[response objectForKey:@"mns"] error:nil];
        if (block) {
            block(roomModel,mnsModel,error);
        }
    }];
}

/**
 获取MnsTopicInfo
 */
+ (void)getMnsTopicInfo:(NSString*)topic tags:(NSArray*)tags block:(void (^)(AlivcWebSocketInfoModel *infoModel,NSError *error))block
{
    NSDictionary *param = @{@"topic":topic,
                            @"subscriptionName":topic};
    [[AlivcRequestManager manager] requestWithHost:@"mns/topic/websocket/info" param:param block:^(NSDictionary *response, NSError *error) {
        
        if (error) {
            if(block)
                block(nil,error);
            return ;
        }
        
        AlivcWebSocketInfoModel *infoModel = [[AlivcWebSocketInfoModel alloc] initWithDictionary: response];
        infoModel.tags = tags;
        infoModel.topicName = topic;
        if(block)
            block(infoModel,error);
    }];
}

/**
 加入直播间成功
 */
+ (void)joinChatRoomWithWebSocketInfoModel:(AlivcWebSocketInfoModel *)model success:(void (^)(void))successBlock error:(void (^)(NSError *error))errorBlock
{
    [[AlivcLiveClient shareClient] joinChatRoomWithWebSocketInfoModel:model success:^{
        if(successBlock)
            successBlock();
    } error:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

/**
 退出直播请求
 */
+ (void)leaveLive:(NSString*)roomId block:(void (^)(NSError *error))block
{
    NSDictionary *param = @{@"roomId":roomId};
    [[AlivcRequestManager manager] requestWithHost:@"live/leave" param:param block:^(NSDictionary *response, NSError *error) {
        if(block)
            block(error);
    }];
}

#pragma mark - ======== 主播端与观众端分割 ========
/**
 发送加入直播请求
 */
+ (void)watchLive:(NSString*)uid roomId:(NSString*)roomId block:(void (^)(MNSInfoModel* mnsInfo, NSError *error))block
{
    NSDictionary *param = @{@"roomId":roomId,
                            @"uid":uid};
    [[AlivcRequestManager manager] requestWithHost:@"live/play" param:param block:^(NSDictionary *response, NSError *error) {
        
        if (error) {
            if(block)
                block(nil,error);
            return ;
        };
        
        MNSInfoModel* mnsModel = [[MNSInfoModel alloc] initWithDictionary:[response objectForKey:@"mns"] error:nil];
        
        if(block)
            block(mnsModel,error);
        
    }];
}

/**
 退出直播间的请求
 */
+ (void)leaveWatch:(NSString*)roomId uid:(NSString*)uid block:(void (^)(NSError *error))block
{
    NSDictionary *param = @{@"roomId":roomId,
                            @"uid":uid};
    [[AlivcRequestManager manager] requestWithHost:@"live/audience/leave" param:param block:^(NSDictionary *response, NSError *error) {
        
        if(block) {
            block(error);
        }
    }];
}

/**
 发送点赞请求
 */
+ (void)likeWatch:(NSString*)uid roomId:(NSString*)roomId block:(void (^)(NSError *error))block
{
    NSDictionary *param = @{@"uid":uid,
                            @"roomId":roomId};
    [[AlivcRequestManager manager] requestWithHost:@"live/like" param:param block:^(NSDictionary *response, NSError *error) {
        
        if (block) {
            block(error);
        }
    }];
}

/**
 退出聊天室
 */
+ (void)quitChatRoomSuccess:(void (^)(void))successBlock error:(void (^)(NSError *error))errorBlock
{
    [[AlivcLiveClient shareClient] quitChatRoomSuccess:^{
        if (successBlock) {
            successBlock();
        }
    } error:^(NSError *error) {
        if(errorBlock)
            errorBlock(error);
    }];
}
@end
