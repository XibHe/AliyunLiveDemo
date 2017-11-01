//
//  LiveRoomViewController.m
//  ALiveDemo
//
//  Created by zyjk_iMac-penghe on 2017/10/30.
//  Copyright © 2017年 zyjk_iMac-penghe. All rights reserved.
//

#import "LiveRoomViewController.h"
#import <AlivcVideoChat/AlivcVideoChat.h>
#import "AlivcLiveAlertView.h"
#import "SendMessageManager.h"
#import "LiveRoomView.h"
#import "AlivcLiveSpotView.h"

@interface LiveRoomViewController ()<AlivcLiveAlertViewDelegate,LiveRoomViewDelegate>

// SDK
@property (nonatomic, strong) NSMutableDictionary *playerParam;         // 参数
@property (nonatomic, strong) AlivcVideoChatParter *mediaPlayerCall;    // 观众端

// 直播间聊天室SDK(AlivcLiveChatRoom.framework)相关
@property (nonatomic, strong) MNSInfoModel *mnsModel;

// UI
@property (nonatomic, strong) LiveRoomView *liveRoomView;

@end

@implementation LiveRoomViewController

- (void)loadView
{
    self.liveRoomView = [[LiveRoomView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.liveRoomView.delegate = self;
    self.view = self.liveRoomView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createMediaPlayer];
}

/**
 创建player
 */
- (void)createMediaPlayer
{
    if(self.playUrl.length == 0) {
        AlivcLiveAlertView *alert = [[AlivcLiveAlertView alloc] initWithTitle:@"提示" icon:nil message:@"直播间暂无直播" delegate:nil buttonTitles:@"OK",nil];
        [alert showInView:self.liveRoomView];
        
        return;
    }
    
    // 初始化参数
    self.mediaPlayerCall = [[AlivcVideoChatParter alloc] init];
    // 添加通知
    [self addVideoChatObserver];
    
    self.playerParam = [[NSMutableDictionary alloc] init];
    NSNumber *dropBufferDuration = [[NSNumber alloc] initWithInt:2000];
    NSNumber *downloadTimeOut = [[NSNumber alloc] initWithInt:15000];
    [self.playerParam setObject:dropBufferDuration forKey:ALIVC_PLAYER_PARAM_DROPBUFFERDURATION];
    [self.playerParam setObject:[NSNumber numberWithInt:1] forKey:ALIVC_PLAYER_PARAM_SCALINGMODE];
    [self.playerParam setObject:downloadTimeOut forKey:ALIVC_PLAYER_PARAM_DOWNLOADIMEOUT];
    [self.mediaPlayerCall setPlayerParam:self.playerParam];
    
    //  开始观看直播。调用该函数将启动直播播放器，并播放获取到的直播流
    int err = [self.mediaPlayerCall startToPlay:[NSURL URLWithString:self.playUrl] view:self.liveRoomView.mediaPalyerView];
    if(err != 0) {
        NSLog(@"preprare failed,error code is %d",(int)err);
        return;
    }
    else {
//        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateInfo) userInfo:nil repeats:YES];
//        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }
    
    // 关闭自动锁屏
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self sendJoinLiveRequest];
}

#pragma mark - ======== 请求 ========
/**
 发送加入直播请求
 */
- (void)sendJoinLiveRequest
{
    if (self.roomId.length == 0) {
        return;
    }
    [SendMessageManager watchLive:self.userUid roomId:self.roomId block:^(MNSInfoModel *mnsInfo, NSError *error) {
        
        if (error) {
            [self showAlertViewWithMessage:[NSString stringWithFormat:@"加入直播间error:%ld", (long)error.code]];
            return ;
        }
        
        self.mnsModel = mnsInfo;
        if (!self.mnsModel) {
            [self showAlertViewWithMessage:@"未请求到mnsModel,加入直播间失败"];
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
            [self showAlertViewWithMessage:[NSString stringWithFormat:@"聊天SDK加入直播间失败error:%ld", (long)error.code]];
            return ;
        }
        
        [SendMessageManager joinChatRoomWithWebSocketInfoModel:infoModel success:^{
            CSLog(@"加入直播间成功");
        } error:^(NSError *error) {
            [self showAlertViewWithMessage:[NSString stringWithFormat:@"聊天SDK加入直播间失败error:%ld", (long)error.code]];
        }];
    }];
}

/**
 *  发送点赞请求
 */
- (void)sendSpotRequest
{
    [SendMessageManager likeWatch:self.userUid roomId:self.roomId block:^(NSError *error) {
        
        if (error) {
            [self showAlertViewWithMessage:[NSString stringWithFormat:@"点赞失败error:%ld", (long)error.code]];
        }
    }];
}

/**
 离开直播间请求
 */
- (void)sendQuitLiveRoomRequest
{
    if (self.roomId.length == 0) {
        return;
    }
    [SendMessageManager leaveWatch:self.roomId uid:self.userUid block:^(NSError *error) {
        if (error) {
            [self showAlertViewWithMessage:[NSString stringWithFormat:@"离开直播间Request error:%ld", (long)error.code]];
            return ;
        }
    }];
}

#pragma mark - LiveRoomViewDelegate
- (void)quitLiveAction
{
    // 如果有连麦，则需关闭连麦
    
    // 通知服务器退出直播间
    [self sendQuitLiveRoomRequest];
    // 关闭播放器
    [self closeMediaPlayer];
    // 退出聊天室(实际并未添加聊天室功能)
    [SendMessageManager quitChatRoomSuccess:^{
        NSLog(@"退出聊天室成功");
    } error:^(NSError *error) {
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)likeLiveAction
{
    AlivcLiveSpotView* spot = [[AlivcLiveSpotView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    [self.view addSubview:spot];
    CGPoint fountainSource = CGPointMake(ScreenWidth - 100, ScreenHeight - 36/2.0 - 10);
    spot.center = fountainSource;
    [spot animateInView:self.view];

    [self sendSpotRequest];
}

- (void)switchCameraAction
{
    [self.mediaPlayerCall switchCamera];
}

- (void)beautyAction:(UIButton *)sender
{
    NSNumber* number = [[NSNumber alloc] initWithBool:sender.selected];
    NSString* key = ALIVC_FILTER_PARAM_BEAUTY_ON;
    NSDictionary* dic = [[NSDictionary alloc] initWithObjectsAndKeys:number, key,nil];
    [self.mediaPlayerCall setFilterParam:dic];
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
    if (alertView.tag == ALIVC_START_ALERT_TAG_ROOM_EXIT) {
        if (buttonIndex == 0) {
            if (self.mediaPlayerCall && self.playUrl) {
                [self.mediaPlayerCall reconnect:[NSURL URLWithString:self.playUrl]];
            }
        }
        if (buttonIndex == 1) {
            
            // 如果有连麦，则需关闭连麦
            
            //通知服务器退出直播间
            [self sendQuitLiveRoomRequest];
            
            //关闭播放器
            [self closeMediaPlayer];
            
            // 退出直播间
            [SendMessageManager quitChatRoomSuccess:^{
                NSLog(@"退出直播间成功");
            } error:^(NSError *error) {
            }];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            [UIApplication sharedApplication].idleTimerDisabled = NO;
        }
    }
}

#pragma mark - ======== Action ========
/**
 关闭拉流播放器
 */
- (void)closeMediaPlayer
{
    if(self.mediaPlayerCall != nil) {
        [self.mediaPlayerCall offlineChat];
        [self.mediaPlayerCall stopPlaying];
    }
    self.mediaPlayerCall = nil;
}

#pragma mark - NSNotification
- (void)addVideoChatObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnPlayerOpenFailed:) name:AlivcVideoChatPlayerOpenFailed object:self.mediaPlayerCall];
}

- (void)OnPlayerOpenFailed:(NSNotification *)notification
{
    NSString* playUrl = nil;
    NSDictionary* diction = [notification userInfo];
    if (diction) {
        playUrl = [diction objectForKey:@"playUrl"];
    }
    if (playUrl == nil) {
        assert(0);
    }

    AlivcLiveAlertView *alert = [[AlivcLiveAlertView alloc] initWithTitle:playUrl icon:nil message:@"打开失败，离开房间" delegate:self buttonTitles:@"重试",@"确定", nil];
    alert.tag = ALIVC_START_ALERT_TAG_ROOM_EXIT;
    [alert showInView:self.liveRoomView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
