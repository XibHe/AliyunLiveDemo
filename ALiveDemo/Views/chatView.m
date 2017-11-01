//
//  LoginView.m
//  DemoAlivcLive
//
//  Created by LYZ on 16/8/22.
//  Copyright © 2016年 Alivc. All rights reserved.
//

#import "chatView.h"

@implementation ChatView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.chatView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.chatView.backgroundColor = [UIColor grayColor];
        self.chatView.hidden = NO;
        [self addSubview:self.chatView];
        //[self bringSubviewToFront:self.chatView];

//        self.nameLabel = [[UILabel alloc] init];
//        self.nameLabel.textColor = [UIColor redColor];
//        self.nameLabel.frame = CGRectMake(0,0, 108, 30);
//        self.nameLabel.font = [UIFont systemFontOfSize:14.f];
//        self.nameLabel.textAlignment = NSTextAlignmentCenter;
//        [self addSubview:self.nameLabel];
        
        [self addCloseButton];
    }
    return self;
}

-(void)addCloseButton{
    UIImage* closeImg = [UIImage imageNamed:@"singalClose"];
    self.closeBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.closeBtn setBackgroundImage:closeImg forState:(UIControlStateNormal)];
    self.closeBtn.frame = CGRectMake(self.frame.size.width-closeImg.size.width,5,closeImg.size.width,closeImg.size.height);
    [self addSubview:self.closeBtn];
    [self.closeBtn addTarget:self action:@selector(closePush:) forControlEvents:UIControlEventTouchUpInside];

    [self bringSubviewToFront:self.closeBtn];
}

- (void)closePush:(UIButton *)sender
{
    if (self.delegate) {
        [self.delegate onClickChatViewCloseButtonWithView:self];
    }
}

@end
