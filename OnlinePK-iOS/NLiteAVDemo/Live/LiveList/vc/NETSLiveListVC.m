//
//  NETSLiveListVC.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/9.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSLiveListVC.h"
#import "NETSLiveListVM.h"
#import "NETSLiveListCell.h"
#import <MJRefresh/MJRefresh.h>
#import "NENavigator.h"
#import "NETSLiveModel.h"
#import "NETSToast.h"
#import "NETSEmptyListView.h"

@interface NETSLiveListVC () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong)   NETSLiveListVM       *viewModel;
@property (nonatomic, strong)   UICollectionView     *collectionView;
@property (nonatomic, strong)   UIButton            *startPkBtn;
@property (nonatomic, strong)   NETSEmptyListView    *emptyView;
@property(nonatomic, assign)    NERoomType          roomtType;
@end

@implementation NETSLiveListVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [[NETSLiveListVM alloc] init];
    }
    return self;
}

- (instancetype)initWithNavRoomType:(NERoomType)roomType {
    if (self = [super init]) {
        _roomtType = roomType;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupViews];
    [self bindAction];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.viewModel load];
}

- (void)setupViews {

    self.title = _roomtType == NERoomTypePkLive ? NSLocalizedString(@"PK直播", nil) : NSLocalizedString(@"多人连麦直播", nil);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = HEXCOLOR(0x000000);
    self.navigationController.navigationBar.topItem.title = @"";

    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.startPkBtn];
    
    [self.collectionView addSubview:self.emptyView];
    self.emptyView.centerX = self.collectionView.centerX;
    self.emptyView.centerY = self.collectionView.centerY - (kIsFullScreen ? 88 : 64);
}

- (void)bindAction
{
    @weakify(self);
    MJRefreshGifHeader *mjHeader = [MJRefreshGifHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self.viewModel load];
    }];
    [mjHeader setTitle:NSLocalizedString(@"下拉更新", nil) forState:MJRefreshStateIdle];
    [mjHeader setTitle:NSLocalizedString(@"下拉更新", nil) forState:MJRefreshStatePulling];
    [mjHeader setTitle:NSLocalizedString(@"更新中...", nil) forState:MJRefreshStateRefreshing];
    mjHeader.lastUpdatedTimeLabel.hidden = YES;
    [mjHeader setTintColor:[UIColor whiteColor]];
    self.collectionView.mj_header = mjHeader;
    
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        if (self.viewModel.isEnd) {
            [NETSToast showToast:NSLocalizedString(@"无更多内容", nil)];
            [self.collectionView.mj_footer endRefreshing];
        } else {
            [self.viewModel loadMore];
        }
    }];
    
    [RACObserve(self.viewModel, datas) subscribeNext:^(NSArray *array) {
        @strongify(self);
        [self.collectionView reloadData];
        self.emptyView.hidden = [array count] > 0;
    }];
    [RACObserve(self.viewModel, isLoading) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (self.viewModel.isLoading == NO) {
            [self.collectionView.mj_header endRefreshing];
            [self.collectionView.mj_footer endRefreshing];
        }
    }];
    [RACObserve(self.viewModel, error) subscribeNext:^(NSError * _Nullable err) {
        if (!err) { return; }
        if (err.code == 1003) {
            [NETSToast showToast:NSLocalizedString(@"直播列表为空", nil)];
        } else {
            NSString *msg = err.userInfo[NSLocalizedDescriptionKey] ?: NSLocalizedString(@"请求直播列表错误", nil);
            [NETSToast showToast:msg];
        }
    }];
}

/// 开始直播
- (void)startLive {
    [[NENavigator shared] showAnchorVCWithRoomType:self.roomtType];
}

#pragma mark - UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.viewModel.datas count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [NETSLiveListCell cellWithCollectionView:collectionView
                                          indexPath:indexPath
                                              datas:self.viewModel.datas];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.viewModel.datas count] > indexPath.row) {
         [[NENavigator shared] showLivingRoom:self.viewModel.datas selectindex:indexPath.row];
    }
}

#pragma mark - lazy load

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = [NETSLiveListCell size];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = 8;
        layout.minimumLineSpacing = 8;
        layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);
        
        CGRect rect = CGRectMake(0, 0, self.view.width, kScreenHeight - (kIsFullScreen ? 34 : 0));
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        [_collectionView registerClass:[NETSLiveListCell class] forCellWithReuseIdentifier:[NETSLiveListCell description]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
    }
    return _collectionView;
}

- (UIButton *)startPkBtn
{
    if (!_startPkBtn) {
        CGFloat topOffset = self.view.height - 100 - (kIsFullScreen ? 34 : 0);
        _startPkBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 100, topOffset, 70, 70)];
        [_startPkBtn setTitle:NSLocalizedString(@"开始直播", nil) forState:UIControlStateNormal];
        _startPkBtn.titleLabel.font = Font_Default(10);
        [_startPkBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _startPkBtn.layer.cornerRadius = 35;
        [_startPkBtn setGradientBackgroundWithColors:@[HEXCOLOR(0x3D8DFF),HEXCOLOR(0x204CFF)] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(0, 1)];
        [_startPkBtn setImage:[UIImage imageNamed:@"start_pk_ico"] forState:UIControlStateNormal];
        [_startPkBtn addTarget:self action:@selector(startLive) forControlEvents:UIControlEventTouchUpInside];
        [_startPkBtn layoutButtonWithEdgeInsetsStyle:QSButtonEdgeInsetsStyleTop imageTitleSpace:10];
    }
    return _startPkBtn;
}

- (NETSEmptyListView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [[NETSEmptyListView alloc] initWithFrame:CGRectZero];
    }
    return _emptyView;
}

- (NETSLiveListVM *)viewModel {
    if (!_viewModel) {
        _viewModel = [[NETSLiveListVM alloc]init];
        _viewModel.roomType = self.roomtType;
    }
    return _viewModel;
}

- (void)dealloc {
    [[NIMSDK sharedSDK].loginManager logout:^(NSError * _Nullable error) {
        YXAlogInfo(@"pk直播主播端销毁,IM登出, error: %@...", error);
    }];
}
@end
