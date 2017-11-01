//
//  AlivcRequestManager.h
//  DemoAlivcLive
//
//  Created by LYZ on 17/1/5.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface AlivcRequestManager : AFHTTPSessionManager

+ (AlivcRequestManager *)manager;

- (void)requestWithHost:(NSString *)host
                  param:(NSDictionary *)param
                  block:(void(^)(NSDictionary *response, NSError *error))block;


@end
