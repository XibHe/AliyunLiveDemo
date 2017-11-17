//
//  LiveRoomView.m
//  ALiveDemo
//
//  Created by zyjk_iMac-penghe on 2017/10/30.
//  Copyright © 2017年 zyjk_iMac-penghe. All rights reserved.
//

#import "LiveRoomView.h"

@interface LiveRoomView()
@property (nonatomic, strong) UIButton *quitLiveBtn;      // 退出直播按钮
@property (nonatomic, strong) UIButton *nickBtn;          // 用户个人信息
@property (nonatomic, strong) UILabel *nameLabel;         // 用户昵称
@property (nonatomic, strong) NSMutableArray<NSDictionary*> *viewMapArray;
@end

@implementation LiveRoomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    self.viewMapArray = [NSMutableArray array];
    
    self.mediaPalyerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.mediaPalyerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.mediaPalyerView];
    
    // 用户个人信息
    self.nickBtn = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    self.nickBtn.frame = CGRectMake(10, 30, 200, 40);
    [self.nickBtn setTitleColor:kAlivcColor forState:(UIControlStateNormal)];
    [self.nickBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateSelected)];
    [self.nickBtn.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
    [self.nickBtn setBackgroundColor:[UIColor colorWithRed:0x6f / 255.0 green:0x6f / 255.0 blue:0x6f / 255.0 alpha:0.5]];
    self.nickBtn.clipsToBounds = YES;
    self.nickBtn.layer.cornerRadius = 20;
    [self addSubview:self.nickBtn];
    
    UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 40, 40)];
    headImg.image = [UIImage imageNamed:@"headImg"];
    [self addSubview:headImg];
    
    // 用户昵称,id
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, 200, 40)];
    self.nameLabel.font = [UIFont systemFontOfSize:17.f];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:NAME];
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:USERID];
    self.nameLabel.text = [NSString stringWithFormat:@"%@(%@)",name,uid];
    [self addSubview:self.nameLabel];
    
    // 退出直播按钮
    self.quitLiveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.quitLiveBtn.frame = CGRectMake(ScreenWidth - 60, 30, 40, 40);
    [self.quitLiveBtn setBackgroundImage:[UIImage imageNamed:@"liveClose"] forState:UIControlStateNormal];
    [self.quitLiveBtn addTarget:self action:@selector(quitLiveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.quitLiveBtn];
    
    // 底部工具按钮(连麦，点赞，相机，滤镜)
    UIButton *disconnectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    disconnectBtn.frame = CGRectMake(ScreenWidth - 60, ScreenHeight - 60, 34, 34);
    [disconnectBtn setBackgroundImage:[UIImage imageNamed:@"disconnect"] forState:UIControlStateNormal];
    [disconnectBtn addTarget:self action:@selector(disconnectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:disconnectBtn];
    
    UIButton *likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    likeBtn.frame = CGRectMake(disconnectBtn.left - 20 - 34, ScreenHeight - 60, 34, 34);
    [likeBtn setBackgroundImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    [likeBtn addTarget:self action:@selector(likeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:likeBtn];
    
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraBtn.frame = CGRectMake(likeBtn.left - 20 - 34, ScreenHeight - 60, 34, 34);
    [cameraBtn setBackgroundImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(cameraBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cameraBtn];
    
    UIButton *beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    beautyBtn.frame = CGRectMake(cameraBtn.left - 20 - 34, ScreenHeight - 60, 34, 34);
    [beautyBtn setBackgroundImage:[UIImage imageNamed:@"beauty"] forState:UIControlStateNormal];
    [beautyBtn addTarget:self action:@selector(beautyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:beautyBtn];
    
    // 连麦视图显示框
    self.pushView = [[ChatView alloc] initWithFrame:[self getChatViewFrameWithIndex:0]];
    self.pushView.delegate = self;
    
    // 输出性能参数
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(ScreenWidth - 250,100,250,350)];
    self.textView.textColor = [UIColor redColor];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.font = [UIFont fontWithName:@"Arial" size:12.0];
    self.textView.userInteractionEnabled = NO;
    [self addSubview:self.textView];
}

- (CGRect)getChatViewFrameWithIndex:(NSInteger)index {
    
    CGRect rect = CGRectZero;
    //    rect.origin.y = kAlivcLiveScreenHeight-192;
    //    rect.origin.x = kAlivcLiveScreenWidth - 110 * (index+2);
    rect.origin.y = ScreenHeight - 80 - 144 * (index+1) - 15 * (index+0);
    rect.origin.x = ScreenWidth - 85;
    rect.size = CGSizeMake(81, 144);
    
    return rect;
}

#pragma amrk - ChatViewCloseDelegate
// 断开连麦按钮触发的事件
//- (void)onClickChatViewCloseButtonWithView:(UIView *)view
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(interruptLiveCall)]) {
//        [self.delegate interruptLiveCall];
//    }
//}

- (void)switchLiveFrame
{
    CGFloat pushViewSizeWidth = self.pushView.frame.size.width;
    NSString *switchStatus = nil;
    if (pushViewSizeWidth < ScreenWidth) {
        [self.pushView setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        [self.mediaPalyerView setFrame:[self getChatViewFrameWithIndex:0]];
        switchStatus = @"1";
    } else {
        [self.pushView setFrame:[self getChatViewFrameWithIndex:0]];
        [self.mediaPalyerView setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        switchStatus = @"0";
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(liveRoomViewControllerSwitchFrame:)]) {
        [self.delegate liveRoomViewControllerSwitchFrame:switchStatus];
    }
}

- (NSArray<UIView *> *)addChatViewsWithArray:(NSArray*)playArray uidArrays:(NSArray*)uidsArray
{
    NSInteger currentChatCount = self.viewMapArray.count;
    if (currentChatCount >= 3) {
        // 如果连麦已经有三个 则返回空 不继续添加连麦窗口
        return nil;
    }
    NSMutableArray *viewArray = [NSMutableArray array];
    
    int count = (int)[playArray count];
    //NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERID];
    for (int index = 0; index < count; index++) {
        
        ChatView *chatView = [[ChatView alloc] initWithFrame:[self getChatViewFrameWithIndex:index + currentChatCount + 1]];
        chatView.tag = 998877 + index;
        //chatView.nameLabel.text = [uidsArray objectAtIndex:index];
        chatView.delegate = self;
        [self addSubview:chatView];
        [viewArray addObject:chatView];
        
        NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
        [dic setObject:chatView forKey:[playArray objectAtIndex:index]];
        [self.viewMapArray addObject:dic];
    }
    return viewArray;
}

/**
 移除某一个连麦对话框
 */
- (void)removeChatViewsWithUrl:(NSString*)playUrl
{
    int findIndex = -1;
    NSURL* url = [NSURL URLWithString:playUrl];
    for (int i=0; i< (int)[self.viewMapArray count]; i++) {
        NSDictionary* dic = [self.viewMapArray objectAtIndex:i];
        
        NSArray* views = [dic allValues];
        UIView* view = [views objectAtIndex:0];
        
        if([dic objectForKey:url] != nil) {
            findIndex = i;
            [view removeFromSuperview];
        }
        
        if (findIndex != -1) {
            [UIView animateWithDuration:0.5 animations:^{
                view.frame = [self getChatViewFrameWithIndex:i - 1];
            }];
            
        }
    }
    
    if (findIndex != -1) {
        [self.viewMapArray removeObjectAtIndex:findIndex];
    }
}

- (void)removeAllChatViews
{
    for (NSDictionary* dic in self.viewMapArray) {
        UIView* view = [[dic allValues] objectAtIndex:0];
        [view removeFromSuperview];
    }
    [self.viewMapArray removeAllObjects];
}

#pragma mark - ButtonAction
- (void)quitLiveBtnClick:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(quitLiveAction)]) {
        [self.delegate quitLiveAction];
    }
}

- (void)disconnectBtnClick:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(connectAction:)]) {
        [self.delegate connectAction:sender];
    }
}

- (void)likeBtnClick:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(likeLiveAction)]) {
        [self.delegate likeLiveAction];
    }
}

- (void)cameraBtnClick:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchCameraAction)]) {
        [self.delegate switchCameraAction];
    }
}

- (void)beautyBtnClick:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(beautyAction:)]) {
        [self.delegate beautyAction:sender];
    }
}

@end
