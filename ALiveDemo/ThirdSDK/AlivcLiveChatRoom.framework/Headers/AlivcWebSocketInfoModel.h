//
//  QPCRWebSocketInfoModel.h
//  AlivcLiveChatRoom
//
//  Created by LYZ on 16/10/21.
//  Copyright © 2016年 Alivc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlivcWebSocketInfoModel : NSObject

@property (nonatomic, strong) NSString *authentication;
@property (nonatomic, strong) NSString *topicWebsocketServerAddress;
@property (nonatomic, strong) NSString *topicWebsocketServerIp;
@property (nonatomic, strong) NSString *accountId;
@property (nonatomic, strong) NSString *accessId;
@property (nonatomic, strong) NSString *subscription;
@property (nonatomic, strong) NSString *date;

@property (nonatomic, strong) NSString *topicName;
@property (nonatomic, strong) NSArray *tags;


- (instancetype)initWithDictionary:(NSDictionary *)dic;


@end
