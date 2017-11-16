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
#import "RecieveMessageManager.h"
#import "LiveRoomView.h"
#import "AlivcLiveSpotView.h"
#import "LiveInviteInfo.h"

// 直播状态
typedef NS_ENUM(NSInteger, ALIVC_LIVE_ROOM_STATUS) {
    ALIVC_LIVE_ROOM_STATUS_NONE = 0,                // 无
    ALIVC_LIVE_ROOM_STATUS_WATCHING = 1,            // 观看直播
    ALIVC_LIVE_ROOM_STATUS_CALLING = 2,             // 准备连麦中
    ALIVC_LIVE_ROOM_STATUS_CHATTING = 3,            // 连麦中
    ALIVC_LIVE_ROOM_STATUS_CHATING_CLOSING = 4,     // 结束连麦中
};

@interface LiveRoomViewController ()<AlivcLiveAlertViewDelegate,LiveRoomViewDelegate,RecieveMessageDelegate>

// SDK
@property (nonatomic, strong) NSMutableDictionary *playerParam;         // 播放器参数
@property (nonatomic, strong) NSMutableDictionary *publisherParam;      // 推流参数
@property (nonatomic, strong) AlivcVideoChatParter *mediaPlayerCall;    // 观众端
@property (nonatomic, strong) NSString *mainUid;

// 直播间聊天室SDK(AlivcLiveChatRoom.framework)相关
@property (nonatomic, strong) MNSInfoModel *mnsModel;

// UI
@property (nonatomic, strong) LiveRoomView *liveRoomView;

@property (nonatomic, assign) ALIVC_LIVE_ROOM_STATUS liveStatus;
@property (nonatomic, strong) NSMutableArray<LiveInviteInfo*> *invitePlayUrlArray;
@property (nonatomic, strong) RecieveMessageManager *mRecieveManager;

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
    self.mRecieveManager = [[RecieveMessageManager alloc] init];
    self.mRecieveManager.delegate = self;
    // 初始化参数
    self.mediaPlayerCall = [[AlivcVideoChatParter alloc] init];
    self.liveStatus = ALIVC_LIVE_ROOM_STATUS_WATCHING;
    self.invitePlayUrlArray = [NSMutableArray array];
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
    self.liveStatus = ALIVC_LIVE_ROOM_STATUS_WATCHING;
    // 关闭自动锁屏
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self sendJoinLiveRequest];
}

/**
 *  开始连麦
 */
- (void)createLiveCallWithPushUrl:(NSString *)pushUrl hostPlayUrl:(NSURL *)hostPlayUrl otherPlayUrls:(NSArray<NSURL *> *)otherPlayUrlArray otherPlayUids:(NSArray<NSString*> *)otherPlayUidArray
{
    // 开始连麦
    if (!self.mediaPlayerCall) {
        return;
    }
    
    int width = 180;
    int height = 320;
    
    self.publisherParam = [[NSMutableDictionary alloc] init];
    NSNumber* frontCamera = [[NSNumber alloc] initWithBool:YES];
    NSNumber* audioSampleRate = [[NSNumber alloc] initWithInt:32000];
    NSNumber* uploadTimeout = [[NSNumber alloc] initWithInt:5000];
    NSNumber* maxBitRate = [[NSNumber alloc] initWithInt:800];
    
    [self.publisherParam setObject:maxBitRate forKey:ALIVC_PUBLISHER_PARAM_MAXBITRATE];
    [self.publisherParam setObject:uploadTimeout forKey:ALIVC_PUBLISHER_PARAM_UPLOADTIMEOUT];
    [self.publisherParam setObject:audioSampleRate forKey:ALIVC_PUBLISHER_PARAM_AUDIOSAMPLERATE];
    [self.publisherParam setObject:frontCamera forKey:ALIVC_PUBLISHER_PARAM_FRONTCAMERAMIRROR];
    
    //设置推流最小码率
    NSNumber* minBitRate = [[NSNumber alloc] initWithInt:200];
    [self.publisherParam setObject:minBitRate forKey:ALIVC_PUBLISHER_PARAM_MINBITRATE];
    
    //设置推流初始码率
    NSNumber* originalBitRate = [[NSNumber alloc] initWithInt:400];
    [self.publisherParam setObject:originalBitRate forKey:ALIVC_PUBLISHER_PARAM_ORIGINALBITRATE];
    
    //设置是横屏推流还是竖屏推流
    NSNumber* landscape = [[NSNumber alloc] initWithInt:NO];
    [self.publisherParam setObject:landscape forKey:ALIVC_PUBLISHER_PARAM_LANDSCAPE];
    
    //设置推流是前置摄像头还是后置摄像头
    NSNumber* cameraPosition = [[NSNumber alloc] initWithInt:cameraPositionFront];
    [self.publisherParam setObject:cameraPosition forKey:ALIVC_PUBLISHER_PARAM_CAMERAPOSITION];
    
    [self.liveRoomView addSubview:self.liveRoomView.pushView];
    
    NSArray *playerViews = [self.liveRoomView addChatViewsWithArray:otherPlayUrlArray uidArrays:otherPlayUidArray];
    
    int ret = [self.mediaPlayerCall onlineChats:pushUrl width:width height:height preview:self.liveRoomView.pushView publisherParam:self.publisherParam hostPlayUrl:hostPlayUrl playerUrls:otherPlayUrlArray playerViews:playerViews];
    
    if (ret != 0) {
        [self.liveRoomView removeAllChatViews];
        [self.liveRoomView.pushView removeFromSuperview];
        [self.mediaPlayerCall offlineChat];
        [self showAlertViewWithMessage:[NSString stringWithFormat:@"连麦失败,ret=%d", ret]];
        return;
    }
    
    NSLog(@"观众SDK开始连麦 %d", ret);
    self.playNotMixUrl = [hostPlayUrl absoluteString];
    self.liveStatus = ALIVC_LIVE_ROOM_STATUS_CHATTING;
}

/**
 *  删除一个连麦
 */
- (void)removeLiveCallWithPlayUrls:(NSArray<NSString *> *)playUrlArray
{
    NSMutableArray* urlArray = [[NSMutableArray alloc] init];
    for (NSString *playUrl in playUrlArray) {
        [urlArray addObject:[NSURL URLWithString:playUrl]];
        for (int i=0; i<[self.invitePlayUrlArray count]; i++) {
            LiveInviteInfo* info = [self.invitePlayUrlArray objectAtIndex:i];
            NSString* currentUrl = info.playUrl;
            if ([currentUrl isEqualToString:playUrl]) {
                [self.liveRoomView removeChatViewsWithUrl:playUrl];
                [self.invitePlayUrlArray removeObject:info];
                break;
            }
        }
    }
    
    int ret = [self.mediaPlayerCall removeChats:urlArray];
    if (ret != 0) {
        [self showAlertViewWithMessage:@"SDK移除连麦失败"];
    }
}
    
#pragma mark - ======== 请求(直播间相关) ========
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

#pragma mark - ======== 请求(连麦相关) ========
/**
 *  发送连麦请求
 */
- (void)sendInviteVideoCallRequest
{
    NSArray* inviteeUids = [[NSArray alloc] initWithObjects:self.hostUid, nil];
    [SendMessageManager inviteVideoCall:self.roomId inviterUid:self.userUid inviteeUids:inviteeUids inviterType:1 block:^(NSError *error) {
        if (error) {
            [self showAlertViewWithMessage:[NSString stringWithFormat:@"发起连麦请求error:%ld", (long)error.code]];
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlertViewWithMessage:@"连麦请求发送成功"];
        });
        
        self.liveStatus = ALIVC_LIVE_ROOM_STATUS_CALLING;
    }];
}

/**
 *  发送结束连麦请求
 */
- (void)sendLeaveVideoCallRequest
{
    [SendMessageManager leaveVideoCall:self.roomId uid:self.userUid block:^(NSError *error) {
        if (error) {
            [self showAlertViewWithMessage:[NSString stringWithFormat:@"离开连麦请求失败error:%ld", (long)error.code]];
            return ;
        }
    }];
}

#pragma mark - LiveRoomViewDelegate
// 退出直播间
- (void)quitLiveAction
{
    // 如果有连麦，则需关闭连麦
    if (self.liveStatus == ALIVC_LIVE_ROOM_STATUS_CHATTING) {
        AlivcLiveAlertView *alert = [[AlivcLiveAlertView alloc] initWithTitle:@"提示" icon:nil message:@"当前正在与主播连麦，请先结束连麦在退出观看" delegate:self buttonTitles:@"取消", @"结束连麦", nil];
        alert.tag = ALIVC_START_ALERT_TAG_VIDEOCALL_EXIT;
        [alert showInView:self.liveRoomView];
        return;
    }
    
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
// 连麦
- (void)connectAction:(UIButton *)sender
{
    if (sender.selected) {
        // 发送结束连麦请求
        [self sendLeaveVideoCallRequest];
        // 断开连麦
        [self closeLiveCall];
    } else {
        // 已经请求连麦中，或正在连麦中，则不进行连麦
        if (self.liveStatus == ALIVC_LIVE_ROOM_STATUS_CALLING || self.liveStatus == ALIVC_LIVE_ROOM_STATUS_CHATTING) {
            return;
        }
        // 发送开始连麦请求
        [self sendInviteVideoCallRequest];
    }
}
// 点赞
- (void)likeLiveAction
{
    AlivcLiveSpotView* spot = [[AlivcLiveSpotView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    [self.view addSubview:spot];
    CGPoint fountainSource = CGPointMake(ScreenWidth - 100, ScreenHeight - 36/2.0 - 10);
    spot.center = fountainSource;
    [spot animateInView:self.view];

    [self sendSpotRequest];
}
// 切换前后摄像头
- (void)switchCameraAction
{
    [self.mediaPlayerCall switchCamera];
}
// 美颜
- (void)beautyAction:(UIButton *)sender
{
    NSNumber* number = [[NSNumber alloc] initWithBool:sender.selected];
    NSString* key = ALIVC_FILTER_PARAM_BEAUTY_ON;
    NSDictionary* dic = [[NSDictionary alloc] initWithObjectsAndKeys:number, key,nil];
    [self.mediaPlayerCall setFilterParam:dic];
    [sender setSelected:!sender.selected];
}

// 断开连麦
- (void)interruptLiveCall
{
    //发送结束连麦请求
    [self sendLeaveVideoCallRequest];
    // 断开连麦
    [self closeLiveCall];
}
// 连麦时预览窗口切换(全屏切换)
- (void)liveRoomViewControllerSwitchFrame:(NSString *)status
{
    NSInteger chatViewInt = [[self.liveRoomView subviews] count];
    if ([status isEqualToString:@"1"]) {
        [self.liveRoomView exchangeSubviewAtIndex:0 withSubviewAtIndex:chatViewInt - 1];
    } else if ([status isEqualToString:@"0"]) {
        [self.liveRoomView exchangeSubviewAtIndex:chatViewInt - 1 withSubviewAtIndex:0];
    }
    [self.liveRoomView layoutIfNeeded];
    NSLog(@"self.liveRoomView.subviews = %@",self.liveRoomView.subviews);
}

#pragma mark - ======== RecieveMessageDelegate (接收消息代理) ========
// 主动发起连麦，收到对方同意连麦消息
- (void)onGetInviteAgreeMessage:(NSString *)inviteeUid inviteeName:(NSString *)inviteeName inviteeRoomId:(NSString *)inviteeRoomId inviterRoomId:(NSString *)inviterRoomId mainPlayUrl:(NSURL *)mainPlayUrl rtmpUrl:(NSString *)rtmpUrl otherPlayUrls:(NSArray *)otherPlayUrls otherPlayUids:(NSArray *)otherPlayUids
{
    self.mainUid = inviteeUid;
    [self createLiveCallWithPushUrl:rtmpUrl hostPlayUrl:mainPlayUrl otherPlayUrls:otherPlayUrls otherPlayUids:otherPlayUids];
    
    for (int i=0; i<[otherPlayUids count]; i++) {
        NSString* uid = [otherPlayUids objectAtIndex:i];
        NSString* url = [[otherPlayUrls objectAtIndex:i] absoluteString];
        LiveInviteInfo *info = [[LiveInviteInfo alloc] init];
        info.uid = uid;
        info.playUrl = url;
        [self.invitePlayUrlArray addObject:info];
    }
}

//不同意连麦
- (void)onGetInviteDisAgreeMessage:(NSString*)inviteeUid inviteeName:(NSString*)inviteeName
{
    if (self.liveStatus == ALIVC_LIVE_ROOM_STATUS_CALLING || self.liveStatus == ALIVC_LIVE_ROOM_STATUS_CHATTING) {
        [self showAlertViewWithMessage:@"对方不同意连麦"];
        self.liveStatus = ALIVC_LIVE_ROOM_STATUS_WATCHING;
    }
}

//收到直播结束消息
- (void)onGetCloseLiveMessage:(NSString*)roomId
{
    AlivcLiveAlertView *alert = [[AlivcLiveAlertView alloc] initWithTitle:@"提示" icon:nil message:@"直播结束" delegate:self buttonTitles:@"重试", @"退出", nil];
    alert.tag = ALIVC_START_ALERT_TAG_ROOM_EXIT;
    [alert showInView:self.liveRoomView];
    return;
}

//离开连麦
- (void)onGetLeaveVideoChatMessage:(LiveInviteInfo*)inviteInfo
{
    //如果自己收到离开消息，则是主播取消了你的连麦
    NSString *uid = inviteInfo.uid;
    if ([uid isEqualToString:self.userUid]){
        //断开推流
        [self closeLiveCall];
        return;
    }
    
    //如果正在连麦，则移除该连麦的播放窗口
    if (self.liveStatus == ALIVC_LIVE_ROOM_STATUS_CALLING || self.liveStatus == ALIVC_LIVE_ROOM_STATUS_CHATTING) {
        [self removeLiveCallWithPlayUrls:@[inviteInfo.playUrl]];
    }
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
    // 退出直播间
    if (alertView.tag == ALIVC_START_ALERT_TAG_ROOM_EXIT) {
        if (buttonIndex == 0) {
            if (self.mediaPlayerCall && self.playUrl) {
                [self.mediaPlayerCall reconnect:[NSURL URLWithString:self.playUrl]];
            }
        }
        if (buttonIndex == 1) {
            
            // 如果有连麦，则需关闭连麦
            if(self.liveStatus == ALIVC_LIVE_ROOM_STATUS_CHATTING){
                [self closeLiveCall];
            }
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
    } else if (alertView.tag == ALIVC_START_ALERT_TAG_VIDEOCALL_EXIT) {
        // 退出连麦
        if (buttonIndex == 1) {
            
            // 若是为全屏连麦视图，则切换至小屏连麦
            NSArray *liveRoomViewArray = [self.liveRoomView subviews];
            if ([liveRoomViewArray[0] isKindOfClass:[ChatView class]]) {
                [self.liveRoomView.pushView setFrame:CGRectMake(ScreenWidth - 85, ScreenHeight - 80 - 144 - 15, 81, 144)];
                [self.liveRoomView.mediaPalyerView setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
                [self.liveRoomView exchangeSubviewAtIndex:[liveRoomViewArray count] - 2 withSubviewAtIndex:0];
                [self.liveRoomView layoutIfNeeded];
                NSLog(@" -----------self.liveRoomView.subviews = %@",self.liveRoomView.subviews);
            }
            
            // 发送结束连麦请求
            [self sendLeaveVideoCallRequest];
            // 关闭连麦
            [self closeLiveCall];
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
    self.liveStatus = ALIVC_LIVE_ROOM_STATUS_NONE;
}
/**
 结束连麦
 */
- (void)closeLiveCall
{
    if (!self.mediaPlayerCall) {
        return;
    }
    
    [self.liveRoomView.pushView removeFromSuperview];
    self.liveRoomView.mediaPalyerView.frame = [UIScreen mainScreen].bounds;
    
    int ret = [self.mediaPlayerCall offlineChat];
    NSLog(@"观众SDK结束连麦 %d", ret);
    
    self.liveStatus = ALIVC_LIVE_ROOM_STATUS_WATCHING;
    [self.invitePlayUrlArray removeAllObjects];
    [self.liveRoomView removeAllChatViews];
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
