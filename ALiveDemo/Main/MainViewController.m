//
//  MainViewController.m
//  ALiveDemo
//
//  Created by zyjk_iMac-penghe on 2017/10/25.
//  Copyright © 2017年 zyjk_iMac-penghe. All rights reserved.
//

#import "MainViewController.h"
#import "StartLiveViewController.h"
#import "SendMessageManager.h"
#import "LiveListCell.h"
#import "AlivcLiveAlertView.h"
#import "LiveRoomViewController.h"
#import "MJRefresh.h"

static NSString *listCellIndentify = @"listCell";

@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *listDataArray;
@property (nonatomic, strong) UITableView *listTableView;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.listDataArray = [NSMutableArray array];
    self.title = @"直播列表";
    [self steupViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self requestList];
}

- (void)steupViews
{
    self.listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
    self.listTableView.rowHeight = ScreenWidth * 132 / 375;
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    [self.view addSubview:self.listTableView];
    
    __weak typeof(self) weakSelf = self;
    self.listTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf requestList];
    }];
    
    UIButton *liveButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    liveButton.frame = CGRectMake((ScreenWidth - 56) / 2, (ScreenHeight - 80), 56, 56);
    [liveButton setBackgroundImage:[UIImage imageNamed:@"create"] forState:(UIControlStateNormal)];
    [liveButton addTarget:self action:@selector(startLiveButtonClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview: liveButton];
}

#pragma mark - ======== 请求列表 ========
- (void)requestList
{
    [SendMessageManager getAppLiveList:^(NSMutableArray<RoomInfoModel *> *roomInfos, NSError *error) {
        [self.listTableView.mj_header endRefreshing];
        
        if (error) {
            NSLog(@"播放列表获取失败:%@", error);
            return ;
        }
        [self.listDataArray removeAllObjects];
        
        for (RoomInfoModel* model in roomInfos) {
            if ([model.name rangeOfString:@"Test_"].location != NSNotFound) {
                [self.listDataArray addObject:model];
            }
        }
        [self.listTableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView registerNib:[UINib nibWithNibName:@"LiveListCell" bundle:nil] forCellReuseIdentifier:listCellIndentify];
    LiveListCell *cell = [tableView dequeueReusableCellWithIdentifier:listCellIndentify];
    
    if (self.listDataArray.count > indexPath.row) {
        RoomInfoModel *model = self.listDataArray[indexPath.row];
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ (ID:%@)", model.name, model.uid];
    }

    return cell;
}

#pragma mark - UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RoomInfoModel *model = self.listDataArray[indexPath.row];
    
    if (model.status == 1) {
        LiveRoomViewController *liveRoomVC = [[LiveRoomViewController alloc] init];
        liveRoomVC.roomId = model.roomId;
        liveRoomVC.hostUid = model.uid;
        liveRoomVC.liveName = model.name;
        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERID];
        liveRoomVC.userUid = userId;
        liveRoomVC.playUrl = model.rtmpPlayUrl;
        [self presentViewController:liveRoomVC animated:YES completion:nil];
    } else {
        AlivcLiveAlertView *alert = [[AlivcLiveAlertView alloc] initWithTitle:@"提示" icon:nil message:@"当前主播还未开始直播，请稍后下拉刷新列表重试" delegate:nil buttonTitles:@"OK",nil];
        [alert showInView:self.view];
    }
}

- (void)startLiveButtonClick:(UIButton *)sender
{
    StartLiveViewController *startLiveVC = [[StartLiveViewController alloc] init];
    startLiveVC.uid = [[NSUserDefaults standardUserDefaults] objectForKey:USERID];
    startLiveVC.liveName = [[NSUserDefaults standardUserDefaults] objectForKey:NAME];
    [self presentViewController:startLiveVC animated:YES completion:nil];
}


@end
