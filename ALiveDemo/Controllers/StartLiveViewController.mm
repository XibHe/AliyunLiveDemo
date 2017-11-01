//
//  StartLiveViewController.m
//  ALiveDemo
//
//  Created by zyjk_iMac-penghe on 2017/10/25.
//  Copyright © 2017年 zyjk_iMac-penghe. All rights reserved.
//

#import "StartLiveViewController.h"
#import <AlivcVideoChat/AlivcVideoChat.h>
#import "SendMessageManager.h"
#import "RecieveMessageManager.h"
#import "AlivcLiveAlertView.h"
#import "SVProgressHUD.h"
#import "StartLiveView.h"
#import "AlivcLiveSpotView.h"

@interface StartLiveViewController ()<AlivcLiveAlertViewDelegate,StartLiveViewDelegate,RecieveMessageDelegate>

// 连麦SDK相关
@property (nonatomic, strong) NSMutableDictionary *publisherParam;
@property (nonatomic, strong) AlivcVideoChatHost *publisherVideoCall;

// 直播间聊天室SDK(AlivcLiveChatRoom.framework)相关
@property (nonatomic, strong) MNSInfoModel *mnsModel;

// 连麦管理
@property (nonatomic, strong) NSString *rtmpURLString;
@property (nonatomic, strong) NSString *roomId;

// UI
@property (nonatomic, strong) StartLiveView *startLiveView;

// 接收消息接收器
@property (nonatomic, strong) RecieveMessageManager *recieveMessageManager;

@end

@implementation StartLiveViewController

- (void)loadView
{
    self.startLiveView = [[StartLiveView alloc] initWithFrame:([UIScreen mainScreen].bounds) ];
    self.startLiveView.delegate = self;
    self.view = self.startLiveView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"正在直播";
    [self createPublisher];
}

#pragma mark - 直播SDK
/**
 *  创建直播预览
 */
- (void)createPublisher
{
    self.recieveMessageManager = [[RecieveMessageManager alloc] init];
    self.recieveMessageManager.delegate = self;
    self.publisherVideoCall = [[AlivcVideoChatHost alloc] init];
    
    int width = 540;
    int height = 960;

    // 参数配置
    self.publisherParam  = [[NSMutableDictionary alloc] init];
    NSNumber* frontCamera = [[NSNumber alloc] initWithBool:cameraPositionFront];
    NSNumber* landscape = [[NSNumber alloc] initWithBool:NO];
    NSNumber* uploadTimeout = [[NSNumber alloc] initWithInt:5000];
    NSNumber* maxBitRate = [[NSNumber alloc] initWithInt:1500];
    NSNumber* cameraMirror = [[NSNumber alloc] initWithBool:YES];
    NSNumber* bitrate = [[NSNumber alloc] initWithInt:800];
    NSNumber* minBitrate = [[NSNumber alloc] initWithInt:400];
    
    [self.publisherParam setObject:maxBitRate forKey:ALIVC_PUBLISHER_PARAM_MAXBITRATE];
    [self.publisherParam setObject:minBitrate forKey:ALIVC_PUBLISHER_PARAM_MINBITRATE];
    [self.publisherParam setObject:bitrate forKey:ALIVC_PUBLISHER_PARAM_ORIGINALBITRATE];
    [self.publisherParam setObject:uploadTimeout forKey:ALIVC_PUBLISHER_PARAM_UPLOADTIMEOUT];
    [self.publisherParam setObject:landscape forKey:ALIVC_PUBLISHER_PARAM_LANDSCAPE];
    [self.publisherParam setObject:frontCamera forKey:ALIVC_PUBLISHER_PARAM_CAMERAPOSITION];
    [self.publisherParam setObject:cameraMirror forKey:ALIVC_PUBLISHER_PARAM_FRONTCAMERAMIRROR];
    
    // 预览
    int ret = [self.publisherVideoCall prepareToPublish:self.startLiveView.publisherView width:width height:height publisherParam:self.publisherParam];
    if (ret != 0) {
        NSLog(@"开启预览失败%d", ret);
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [self sendCreateLiveRequest];
}

#pragma mark - ======== 请求 ========
/**
 创建直播请求
 */
- (void)sendCreateLiveRequest
{
    [SVProgressHUD show];
    [SendMessageManager creatLive:self.uid description:self.liveName block:^(RoomInfoModel *roomInfo, MNSInfoModel *mnsInfo, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlertViewWithMessage:[NSString stringWithFormat:@"创建直播失败error:%ld", (long)error.code]];
            });
            return;
        }
        [SVProgressHUD dismiss];
        self.rtmpURLString = roomInfo.rtmpUrl;
        self.roomId = roomInfo.roomId;
        self.mnsModel = mnsInfo;
        if (!self.mnsModel) {
            AlivcLiveAlertView *alert = [[AlivcLiveAlertView alloc] initWithTitle:@"提示" icon:nil message:@"未请求到mnsModel,加入直播间失败" delegate:nil buttonTitles:@"OK",nil];
            [alert showInView:self.view];
            return ;
        }
        [self sendRequestLiveChatRoomInfoWithTopicName:self.mnsModel.topic Tags:@[self.mnsModel.roomTag, self.mnsModel.userRoomTag]];
    }];
}

/**
 *  获取直播间infoModel请求
 */
- (void)sendRequestLiveChatRoomInfoWithTopicName:(NSString *)topic Tags:(NSArray *)tags
{
    [SendMessageManager getMnsTopicInfo:topic tags:tags block:^(AlivcWebSocketInfoModel *infoModel, NSError *error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (error.code < 0) {
                    //self.isNeedReconnectIM = YES;
                    return ;
                }
                
                [self showAlertViewWithMessage:[NSString stringWithFormat:@"获取info Model error:%ld", (long)error.code]];
            });
            return ;
        }
        [SendMessageManager joinChatRoomWithWebSocketInfoModel:infoModel success:^{
            NSLog(@"加入直播间成功");
            // 很重要，决定了直播列表中是否存在正在直播的房间。
            [self.publisherVideoCall startToPublish:self.rtmpURLString];
        } error:^(NSError *error) {
            [self showAlertViewWithMessage:[NSString stringWithFormat:@"聊天SDK加入直播间失败error:%ld", (long)error.code]];
        }];
    }];
}

/**
 发送退出直播请求
 */
- (void)sendCloseLiveRequest
{
    [SendMessageManager leaveLive:self.roomId block:^(NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlertViewWithMessage:[NSString stringWithFormat:@"关闭直播失败error:%ld", (long)error.code]];
            });
            return ;
        }
    }];
}

#pragma mark - StartLiveViewDelegate
- (void)quitLiveAction
{
    // 发送退出直播请求
    [self sendCloseLiveRequest];
    // 离开直播（完全关闭）
    [self finishLive];
    // 退出聊天室(实际并未添加聊天室功能)
    [SendMessageManager quitChatRoomSuccess:^{
        NSLog(@"SDK退出聊天室成功");
    } error:^(NSError *error) {
    }];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchCameraAction
{
    [self.publisherVideoCall switchCamera];
}

- (void)beautyAction:(UIButton *)sender
{
    NSNumber* number = [[NSNumber alloc] initWithBool:sender.selected];
    NSString* key = ALIVC_FILTER_PARAM_BEAUTY_ON;
    NSDictionary* dic = [[NSDictionary alloc] initWithObjectsAndKeys:number, key,nil];
    [self.publisherVideoCall setFilterParam:dic];
    [sender setSelected:!sender.selected];
}

#pragma mark - AlertView
- (void)showAlertViewWithMessage:(NSString *)message
{
    AlivcLiveAlertView *alert = [[AlivcLiveAlertView alloc] initWithTitle:@"提示" icon:nil message:message delegate:self buttonTitles:@"OK", nil];
    [alert showInView:self.view];
}

#pragma mark - AlivcLiveAlertViewDelegate
- (void)alertView:(AlivcLiveAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

}

#pragma mark - ======== Action ========
- (void)finishLive
{
    if (self.publisherVideoCall) {
        [self.publisherVideoCall stopPublishing];
        [self.publisherVideoCall finishPublishing];
        self.publisherVideoCall = nil;
    }
}

#pragma mark - RecieveMessageDelegate
// 接收到的点赞
- (void)onGetLikeMessage:(NSString *)uid name:(NSString *)name
{
    //自己不接收自己的消息
    if ([self.uid isEqualToString:uid])
        return;
    
    AlivcLiveSpotView *spot = [[AlivcLiveSpotView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    [self.view addSubview:spot];
    CGPoint fountainSource = CGPointMake(ScreenWidth - 100, ScreenHeight - 36/2.0 - 10);
    spot.center = fountainSource;
    [spot animateInView:self.view];
}

@end
