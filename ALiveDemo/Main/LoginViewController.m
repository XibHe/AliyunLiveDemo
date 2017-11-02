//
//  LoginViewController.m
//  ALiveDemo
//
//  Created by zyjk_iMac-penghe on 2017/10/26.
//  Copyright © 2017年 zyjk_iMac-penghe. All rights reserved.
//

#import "LoginViewController.h"
#import "AlivcLiveAlertView.h"
#import "MainViewController.h"
#import "SendMessageManager.h"
#import "SVProgressHUD.h"

@interface LoginViewController ()

@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UIButton *nextButton;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"登录";
    [self steupView];
}

- (void)steupView
{
    int w = 343;
    int x = ScreenWidth / 2 - 343 / 2;
    if (x<10) {
        x = 10;
        w = ScreenWidth - 20;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *nameView = [[UIView alloc] initWithFrame:CGRectMake(x, 130, w, 40)];
    nameView.backgroundColor = [UIColor colorWithRed:240 / 255.0 green:240 / 255.0 blue:240 / 255.0 alpha:1];
    [nameView.layer setMasksToBounds:YES];
    nameView.layer.borderWidth=1;
    nameView.layer.borderColor =  [[UIColor grayColor] CGColor];
    [nameView.layer setCornerRadius:20.0f];
    [self.view addSubview:nameView];
    
    self.nameTextField = [[UITextField alloc] initWithFrame: CGRectMake(10, 0, w-10, 40)];
    self.nameTextField.textColor = kAlivcColor;
    self.nameTextField.borderStyle = UITextBorderStyleNone;
    self.nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameTextField.placeholder = @"用户名";
    self.nameTextField.textAlignment = NSTextAlignmentLeft;
    [nameView addSubview:self.nameTextField];
    
    self.nextButton = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    self.nextButton.frame = CGRectMake(x, CGRectGetMaxY(nameView.frame) + 30, w, 40);
    [self.nextButton setTitleColor:kAlivcColor forState:(UIControlStateNormal)];
    [self.nextButton setTitleColor:[UIColor grayColor] forState:(UIControlStateSelected)];
    [self.nextButton.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
    [self.nextButton setBackgroundColor:[UIColor colorWithRed:0x87 / 255.0 green:0x4b / 255.0 blue:0xe0 / 255.0 alpha:1]];
    [self.nextButton setTitle:@"登  录" forState:UIControlStateNormal];
    self.nextButton.clipsToBounds = YES;
    self.nextButton.layer.cornerRadius = 20;
    [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(loginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextButton];
    
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 358, ScreenWidth, 358)];
    [bgImgView setImage:[UIImage imageNamed:@"BG"]];
    [self.view addSubview:bgImgView];
    [self.view sendSubviewToBack:bgImgView];
}

- (void)loginBtnClick:(UIButton *)sender
{
    if (self.nameTextField.text.length == 0) {
        AlivcLiveAlertView *alert = [[AlivcLiveAlertView alloc] initWithTitle:@"提示" icon:nil message:@"请输入用户名" delegate:nil buttonTitles:@"OK",nil];
        [alert showInView:self.view];
        return;
    }
    
    [SVProgressHUD show];
    NSString *userName = [NSString stringWithFormat:@"MyLive_%@",self.nameTextField.text];
    [SendMessageManager userLogIn:userName block:^(UserInfo *userInfo, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                AlivcLiveAlertView *alert = [[AlivcLiveAlertView alloc] initWithTitle:@"提示" icon:nil message:[NSString stringWithFormat:@"登录失败error:%ld", (long)error.code] delegate:nil buttonTitles:@"OK",nil];
                [alert showInView:self.view];
            });
            return ;
        }
        
        [SVProgressHUD dismiss];
        NSString *uid = userInfo.id;
        NSString *name = userInfo.name;
        // 存储用户id和用户名
        [[NSUserDefaults standardUserDefaults] setObject:uid forKey:USERID];
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:NAME];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:firstLaunchApp];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[MainViewController alloc] init]];
        [UIApplication sharedApplication].keyWindow.rootViewController = nav;
    }];
    
}

@end
