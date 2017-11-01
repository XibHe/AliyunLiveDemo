//
//  LoginView.h
//  DemoAlivcLive
//
//  Created by LYZ on 16/8/22.
//  Copyright © 2016年 Alivc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatViewCloseDelegate <NSObject>

- (void)onClickChatViewCloseButtonWithView:(UIView*)view;

@end

@interface ChatView : UIView

@property (nonatomic, strong) UIView *chatView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, assign) id<ChatViewCloseDelegate> delegate;

@end
