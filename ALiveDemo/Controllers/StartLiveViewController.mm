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
#import "LiveInviteInfo.h"

// 直播状态
typedef NS_ENUM(NSInteger, ALIVC_START_LIVE_STATUS) {
    ALIVC_START_LIVE_STATUS_NONE = 0,               // 无
    ALIVC_START_LIVE_STATUS_LIVING = 1,             // 直播中 (无人连麦)
    ALIVC_START_LIVE_STATUS_CALLING = 2,            // 连麦连接中
    ALIVC_START_LIVE_STATUS_CHATTING = 3,           // 连麦中 1名
    ALIVC_START_LIVE_STATUS_CHATTING_CLOSING = 4,   // 结束连麦中
};
@interface StartLiveViewController ()<AlivcLiveAlertViewDelegate,StartLiveViewDelegate,RecieveMessageDelegate>

// 连麦SDK相关
@property (nonatomic, strong) NSMutableDictionary *playerParam;     // 推流播放器参数
@property (nonatomic, strong) NSMutableDictionary *publisherParam;
@property (nonatomic, strong) AlivcVideoChatHost *publisherVideoCall;

// 直播间聊天室SDK(AlivcLiveChatRoom.framework)相关
@property (nonatomic, strong) MNSInfoModel *mnsModel;

// 连麦管理
@property (nonatomic, assign) ALIVC_START_LIVE_STATUS liveStatus;                    // 直播状态
@property (nonatomic, strong) NSString *rtmpURLString;                               // 推流url
@property (nonatomic, strong) NSMutableArray<LiveInviteInfo *> *currentInviterArray; // 当前连麦的全部uid
@property (nonatomic, strong) NSString *roomId;

// UI
@property (nonatomic, strong) StartLiveView *startLiveView;

// 消息接收器
@property (nonatomic, strong) RecieveMessageManager *recieveMessageManager;

@property (nonatomic, strong) NSMutableArray *inviterAudienceList; // 主播同意列表
@property (nonatomic, strong) NSMutableArray *interruptUids;       // 断流列表
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
    self.currentInviterArray = [NSMutableArray array];
    self.inviterAudienceList = [NSMutableArray array];
    self.interruptUids = [NSMutableArray array];
    
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

#pragma mark - ======== 请求(直播相关) ========
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

#pragma mark - ======== 请求(连麦相关) ========
/**
 *  发送获取连麦消息(发送是否同意连麦)
 */
- (void)sendInviteVideoCallFeedbackRequestWithUid:(NSString *)inviterUid status:(int)status inviterType:(int)inviterType
{
    [SendMessageManager sendVideoCallFeedBack:inviterUid inviteeUid:self.uid status:status inviterType:inviterType inviteeType:2 block:^(NSURL *mainPlayUrl, NSArray<NSURL *> *playUrls, NSArray<NSString *> *playUids, NSString *rtmpUrl, NSError *error) {
        
        if (error) {
            [self showAlertViewWithMessage:[NSString stringWithFormat:@"连麦反馈请求失败%ld", (long)error.code]];
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

#pragma mark - ======== Action ========
- (void)finishLive
{
    //正在连麦先结束连麦
    if (self.liveStatus == ALIVC_START_LIVE_STATUS_CHATTING) {
        [self closeLiveCall];
    }
    if (self.publisherVideoCall) {
        [self.publisherVideoCall stopPublishing];
        [self.publisherVideoCall finishPublishing];
        self.publisherVideoCall = nil;
    }
}

/**
 *  创建连麦，初始化多人连麦播放器
 */
- (void)createLiveCallWithInviteePlayUrls:(NSArray<NSURL*> *)inviteePlayUrlArray uids:(NSArray<NSString*> *)inviteePlayUidArray
{
    // 连麦
    self.playerParam = [[NSMutableDictionary alloc] init];
    
    //设置播放丢帧的时间阈值，缓冲区超过1s，则进行丢帧
    NSNumber* dropBufferDuration = [[NSNumber alloc] initWithInt:500];
    [self.playerParam setObject:dropBufferDuration forKey:ALIVC_PLAYER_PARAM_DROPBUFFERDURATION];
    
    //设置播放渲染模式
    NSNumber* scalingMode = [NSNumber numberWithInt:scalingModeAspectFitWithCropping];
    [self.playerParam setObject:scalingMode forKey:ALIVC_PLAYER_PARAM_SCALINGMODE];
    
    //设置播放下载超时时间
    NSNumber* downloadTimeout = [[NSNumber alloc] initWithInt:20000];
    [self.playerParam setObject:downloadTimeout forKey:ALIVC_PLAYER_PARAM_DOWNLOADIMEOUT];
    
    [self.publisherVideoCall setPlayerParam:self.playerParam];
    
    NSArray *inviteViews = [self.startLiveView addChatViewsWithArray:inviteePlayUrlArray uids:inviteePlayUidArray];
    
    int ret = [self.publisherVideoCall launchChats:inviteePlayUrlArray views:inviteViews];
    if (ret != 0) {
        [self showAlertViewWithMessage:[NSString stringWithFormat:@"SDK连麦初始化失败,ret=%d", ret]];
    }
    self.liveStatus = ALIVC_START_LIVE_STATUS_CHATTING;
}

/**
 *  添加连麦
 */
- (void)addLiveCallWithPlayUrls:(NSArray<NSURL *> *)playUrlArray uids:(NSArray<NSString*> *)playUidArray
{
//    NSArray *inviteViews = [self.startLiveView addChatViewsWithArray:playUrlArray uids:playUidArray];
//    int ret = [self.publiserVideoCall addChats:playUrlArray views:inviteViews];
//    if (ret != 0) {
//        [self showAlertViewWithMessage:@"SDK添加连麦失败"];
//    }
//    self.liveStatus = ALIVC_START_LIVE_STATUS_CHATTING;
}

/**
 *  结束连麦
 */
- (void)closeLiveCall
{
    [self.startLiveView removeAllChatViews];
    if (self.publisherVideoCall) {
        int ret = [self.publisherVideoCall abortChat];
        NSLog(@"结束连麦:%d", ret);
    }
    self.liveStatus = ALIVC_START_LIVE_STATUS_LIVING;
    [self.currentInviterArray removeAllObjects];
    [self.inviterAudienceList removeAllObjects];
    
    [self.interruptUids removeAllObjects];
}

#pragma mark - ======== RecieveMessageDelegate (接收消息代理) ========
// 接收到连麦请求
- (void)onGetInviteMessage:(NSString *)inviterUid inviterName:(NSString *)inviterName inviterType:(int)inviterType
{
    //todo: 未判断已经连麦的人数，超过3人则返回
    if (inviterType == 2) {
        NSLog(@"主播不能和主播进行连麦");
        return;
    }
    for (LiveInviteInfo* info in self.currentInviterArray) {
        if ([info.uid isEqualToString:inviterUid]) {
            NSLog(@"该用户已经在连麦中");
            return;
        }
    }
    self.liveStatus = ALIVC_START_LIVE_STATUS_CALLING;
    [self.inviterAudienceList addObject:inviterUid];
    //弹出是否同意的对话框
    AlivcLiveAlertView *alert = [[AlivcLiveAlertView alloc] initWithTitle:@"收到连麦请求" icon:nil message:inviterUid delegate:self buttonTitles:@"拒绝连麦", @"同意连麦",nil];
    alert.tag = ALIVC_START_ALERT_TAG_VIDEOCALL_INVITE;
    [alert showInView:self.startLiveView];
}

//推流消息
- (void)onGetStartLiveMessage:(NSString *)roomId uid:(NSString *)uid name:(NSString *)name playUrl:(NSString *)playUrl
{
    BOOL bFind = NO;
    for (NSString* interruptId in self.interruptUids) {
        if ([interruptId isEqualToString:uid]) {
            bFind = YES;
            [self.interruptUids removeObject:interruptId];
            break;
        }
    }
    
    if ([self.uid isEqualToString:uid] == YES) {
        return;
    }
    
    bFind = NO;
    for (NSString* strUid in self.inviterAudienceList) {
        if ([strUid isEqualToString:uid]) {
            bFind = YES;
            break;
        }
    }
    
    if (bFind == NO){
        [self showAlertViewWithMessage:@"提示：该推流的用户不在列表中"];
        return;
    }
    
    //对方已经推流，可以打开对方地址进行播放
    NSURL* url = [NSURL URLWithString:playUrl];
    
    //如果已经存在，则返回，对方有可能重复推流
    for (LiveInviteInfo* info in self.currentInviterArray) {
        if ([info.playUrl isEqualToString:playUrl]) {
            return;
        }
    }
    
    // 创建连麦，初始化多人连麦播放器
    if ([self.currentInviterArray count] == 0) {
        [self createLiveCallWithInviteePlayUrls:@[url] uids:@[uid]];
    }
    else {
    // 继续添加连麦
        [self addLiveCallWithPlayUrls:@[url] uids:@[uid]];
    }
    
    bFind = NO;
    for (LiveInviteInfo* info in self.currentInviterArray) {
        if ([info.uid isEqualToString:uid]) {
            info.name = name;
            info.playUrl = playUrl;
            info.roomId = roomId;
            bFind = YES;
            break;
        }
    }
    
    if (bFind == NO) {
        LiveInviteInfo* info = [[LiveInviteInfo alloc] init];
        info.uid = uid;
        info.name = name;
        info.playUrl = playUrl;
        info.roomId = roomId;
        
        [self.currentInviterArray addObject:info];
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
    if (alertView.tag == ALIVC_START_ALERT_TAG_VIDEOCALL_INVITE) {
        NSString* inviterUid = alertView.message;
        
        if (buttonIndex == 0) {
            // 不同意连麦
            [self sendInviteVideoCallFeedbackRequestWithUid:inviterUid status:2 inviterType:1];
        }
        if (buttonIndex == 1) {
            // 同意连麦
            [self sendInviteVideoCallFeedbackRequestWithUid:inviterUid status:1 inviterType:1];
        }
    }
}

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
