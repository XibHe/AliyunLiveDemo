//
//  AlivcRequestManager.m
//  DemoAlivcLive
//
//  Created by LYZ on 17/1/5.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import "AlivcRequestManager.h"

@implementation AlivcRequestManager

+ (AlivcRequestManager *)manager {
    static AlivcRequestManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AlivcRequestManager alloc] initWithBaseURL:[NSURL URLWithString:kAlivcLiveHost]];
    });
    return manager;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    
    self = [super initWithBaseURL:url];
    if (self) {
        self.requestSerializer.timeoutInterval = 30;
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html",@"Type-Text",@"Content-Type", nil];
    }
    return self;
}

- (void)requestWithHost:(NSString *)host param:(NSDictionary *)param block:(void (^)(NSDictionary *response, NSError *error))block {
    
    [self POST:host parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        CSLog(@"host: %@ *** response:%@", host, responseObject);
        
        if ([responseObject[@"code"] integerValue] == 200) {
            block(responseObject[@"data"], nil);
        } else {
            NSError *error = [NSError errorWithDomain:@"com.alivc.live" code:[responseObject[@"code"] integerValue] userInfo:responseObject[@"message"]];
            NSLog(@"message:%@", responseObject[@"message"]);
            block(nil, error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(nil, error);
    }];
}

@end
