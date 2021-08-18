//
//  NETSAnchorVC.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/10.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSAnchorVC.h"
#import "NEMenuViewController.h"
#import "NETSRequestManageMainController.h"
#import "NTESActionSheetNavigationController.h"
#import "NETSConnectStatusViewController.h"


#import "NETSAnchorBottomPanel.h"
#import "NETSAnchorCoverSetting.h"
#import "UIButton+NTES.h"
#import "NETSWarnToast.h"
#import "NETSBeautySettingActionSheet.h"
#import "NETSFilterSettingActionSheet.h"
#import "NETSLiveSettingActionSheet.h"
#import "NTESKeyboardToolbarView.h"
#import "TopmostView.h"
#import "NETSAnchorTopInfoView.h"
#import "NETSInputToolBar.h"
#import "NETSMoreSettingActionSheet.h"
#import "NETSAudioMixingActionSheet.h"
#import "NETSPkStatusBar.h"
#import "NETSChoosePKSheet.h"
#import "NETSLiveChatView.h"
#import "NETSInvitingBar.h"
#import "NETSToast.h"
#import "NETSInviteeInfoView.h"
#import "NETSMutiConnectView.h"
#import "NETSLiveEndView.h"

#import "AppKey.h"
#import "NETSLiveConfig.h"
#import "NETSLiveSegmentedSettingModel.h"
#import "NETSFUManger.h"
#import "NETSAudienceNum.h"
#import "NETSLiveChatViewHandle.h"
#import "NETSLiveModel.h"
#import "NETSChatroomService.h"
#import "NETSLiveAttachment.h"
#import "NETSLiveUtils.h"
#import "NENavigator.h"
#import "NETSCanvasModel.h"
#import "NETSPushStreamService.h"
#import "NETSPkService.h"
#import "NETSPkService+Inviter.h"
#import "NETSPkService+Invitee.h"
#import "NETSPkService+im.h"
#import "IQKeyboardManager.h"
#import "NETSGCDTimer.h"
#import <AVFoundation/AVCaptureDevice.h>
#import "NETSLiveApi.h"
#import "NETSAnchorChatroomMessageHandle.h"
#import "NETSLiveAttachment.h"
#import "Reachability.h"

@interface NETSAnchorVC ()
<
    NETSAnchorBottomPanelDelegate,
    NERtcEngineDelegateEx,
    NETSInputToolBarDelegate,
    NETSMoreSettingActionSheetDelegate,
    NETSLiveChatViewHandleDelegate,
    NETSChoosePKSheetDelegate,
    NETSInvitingBarDelegate,
    NTESKeyboardToolbarDelegate,
    NETSPkServiceDelegate, NETSPkInviterDelegate, NETSPkInviteeDelegate, NETSPassThroughHandleDelegate,
    NETSMutiConnectViewDelegate,
    NETSAnchorChatroomMessageHandleDelegate
>

/// 绘制单人直播摄像头采集
@property (nonatomic, strong)   UIView                  *singleRender;
/// 单人直播canvas模型
@property (nonatomic, strong)   NETSCanvasModel         *singleCanvas;
/// 绘制摄像头采集
@property (nonatomic, strong)   UIView                  *localRender;
/// 本地canvas模型
@property (nonatomic, strong)   NETSCanvasModel         *localCanvas;
/// 远端视频面板
@property (nonatomic, strong)   UIView                  *remoteRender;
/// 远端canvas模型
@property (nonatomic, strong)   NETSCanvasModel         *remoteCanvas;
/// 底部面板
@property (nonatomic, strong)   NETSAnchorBottomPanel   *bottomPanel;
/// 键盘工具条
@property (nonatomic, strong)   NTESKeyboardToolbarView *toolBar;
/// 封面设置面板
@property (nonatomic, strong)   NETSAnchorCoverSetting  *settingPanel;
/// 返回按钮
@property (nonatomic, strong)   UIButton                *backBtn;
/// 切换摄像头按钮
@property (nonatomic, strong)   UIButton                *switchCameraBtn;
/// 试用提示
@property (nonatomic, strong)   NETSWarnToast           *warnToast;
/// 主播信息视图
@property (nonatomic, strong)   NETSAnchorTopInfoView   *anchorInfo;
/// 直播中 观众数量视图
@property (nonatomic, strong)   NETSAudienceNum         *audienceInfo;
/// 直播中 底部工具条
@property (nonatomic, strong)   NETSInputToolBar        *livingInputTool;
/// 邀请别人PK按钮
@property (nonatomic, strong)   UIButton                *pkBtn;
/// 聊天视图
@property (nonatomic, strong)   NETSLiveChatView        *chatView;
/// 聊天室代理
@property (nonatomic, strong)   NETSLiveChatViewHandle  *chatHandle;
//分离后的主播聊天室代理
@property (nonatomic, strong)   NETSAnchorChatroomMessageHandle  *anchorMessageHandle;

/// pk状态条
@property (nonatomic, strong)   NETSPkStatusBar         *pkStatusBar;
/// pk邀请状态条
@property (nonatomic, strong)   NETSInvitingBar         *pkInvitingBar;
//请求上麦状态条
@property (nonatomic, strong)   NETSInvitingBar         *requestConnectMicBar;
/// 被邀请者信息视图
@property (nonatomic, strong)   NETSInviteeInfoView     *inviteeInfo;

/// 己方加入视音频房间信号
@property (nonatomic, strong)   RACSubject      *joinedPkChannelSubject;
/// 服务端透传pk开始信号
@property (nonatomic, strong)   RACSubject      *serverStartPkSubject;

/// pk胜利图标
@property (nonatomic, strong)   UIImageView     *pkSuccessIco;
/// pk失败图标
@property (nonatomic, strong)   UIImageView     *pkFailedIco;

/// pk直播服务类
@property (nonatomic, strong)   NETSPkService   *pkService;
/// 是否接受pk邀请对话框
@property (nonatomic, strong)   UIAlertController   *pkAlert;
//多人连麦视图
@property (nonatomic, strong)   NETSMutiConnectView   *connectMicView;
//直播间模型
@property(nonatomic, strong) NETSCreateLiveRoomModel *liveRoomModel;
//已上麦人员
@property(nonatomic, strong) NSArray <NETSConnectMicMemberModel *>*connectMicArray;
//已上麦人员uid
@property(nonatomic, strong) NSArray*connectMicUidArray;

//断网检测
@property(nonatomic, assign) BOOL isBrokenNetwork;
//直播间关闭的遮罩
@property(nonatomic, strong) NETSLiveEndView *liveClosedMask;
/// 网络监测类
@property(nonatomic, strong) Reachability               *reachability;
@end

@implementation NETSAnchorVC

- (instancetype)init
{
    self = [super init];
    if (self) {

        _chatHandle = [[NETSLiveChatViewHandle alloc] initWithDelegate:self];
        [[NIMSDK sharedSDK].chatManager addDelegate:_chatHandle];
        [[NIMSDK sharedSDK].chatManager addDelegate:self.anchorMessageHandle];
        [[NIMSDK sharedSDK].chatroomManager addDelegate:_chatHandle];
        [[NIMSDK sharedSDK].systemNotificationManager addDelegate:_chatHandle];

        _pkService = [[NETSPkService alloc] initWithDelegate:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        // 监测网络
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        self.reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
        [self.reachability startNotifier];
        _joinedPkChannelSubject = [RACSubject subject];
        _serverStartPkSubject = [RACSubject subject];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = HEXCOLOR(0x1b1919);
    
    // 重置更多设置
    [[NETSLiveConfig shared] resetConfig];
    // 重置美颜配置
    [[NETSFUManger shared] resetSkinParams];
    // 重置滤镜配置
    [[NETSFUManger shared] resetFilters];
    
    [self layoutPreview];
    [self layoutRenders];
    [self bindAction];
    [self setupRTCEngine];
    
    [self _authCameraAndPrevew];

}

- (void)_authCameraAndPrevew
{
    void(^quitBlock)(void) = ^(void) {
        [NETSToast showToast:@"直播需要开启相机权限"];
        ntes_main_sync_safe(^{
            [[NENavigator shared].navigationController popViewControllerAnimated:YES];
        });
    };
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            quitBlock();
            break;
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (!granted) {
                    quitBlock();
                } else {
                    dispatch_queue_t queue= dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1* NSEC_PER_SEC)), queue, ^{
                        ntes_main_async_safe(^{
                            [self startPrevew];
                        });
                    });
                }
            }];
        }
            break;
        case AVAuthorizationStatusAuthorized:
        {
            ntes_main_async_safe(^{
                [self startPrevew];
            });
        }
            break;
        default:
            break;
    }
}

- (void)dealloc {
    // 关闭屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NIMSDK sharedSDK].chatManager removeDelegate:self.anchorMessageHandle];
    YXAlogInfo(@"dealloc NETSAnchorVC: %p...", self);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)bindAction
{
    @weakify(self);
    [RACObserve(self.pkService, liveStatus) subscribeNext:^(id  _Nullable x) {
        ntes_main_async_safe(^{
            @strongify(self);
            NSString *pkBtnIco = (self.pkService.liveStatus != NETSPkServicePkLive) ? @"pk_ico" : @"end_pk_ico";
            [self.pkBtn setImage:[UIImage imageNamed:pkBtnIco] forState:UIControlStateNormal];
            NSString *requestIcon = (self.pkService.liveStatus != NETSPkServicePkLive) ? @"connectMic_able" : @"connectMic_disable";
            [self.livingInputTool scenarioChanged:requestIcon];
        });
    }];
    
    [RACObserve(self.pkService, singleRoom) subscribeNext:^(NETSCreateLiveRoomModel*  _Nullable room) {
        @strongify(self);
        if (!room) { return; }
        [self.anchorInfo installWithAvatar:room.avatar nickname:room.nickname wealth:0];
    }];
    
    RACSignal *signal = [self.joinedPkChannelSubject zipWith:self.serverStartPkSubject];
    [signal subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        if (![tuple.first isKindOfClass:[NETSPassThroughHandlePkStartData class]]) {
            return;
        }
        NETSPassThroughHandlePkStartData *data = (NETSPassThroughHandlePkStartData *)tuple.first;
        [self _pushPkLiveStreamWithData:data];
    }];
}

- (void)startPrevew
{
    NERtcVideoCanvas *canvas = [self setupSingleCanvas];
    int setLocalCanvasRes = [[NERtcEngine sharedEngine] setupLocalVideoCanvas:canvas];
    YXAlogInfo(@"设置本地视频画布, res: %d", setLocalCanvasRes);
    
    int previewRes = [[NERtcEngine sharedEngine] startPreview];
    YXAlogInfo(@"开启预览, res: %d", previewRes);
    if (previewRes == 0) {
        self.pkService.liveStatus = NETSPkServicePrevew;
    }
}

/// 布局视频渲染视图
- (void)layoutRenders
{
    [self.view addSubview:self.localRender];
    [self.view addSubview:self.remoteRender];
    [self.view addSubview:self.singleRender];
    
    CGFloat anchorInfoBottom = (kIsFullScreen ? 44 : 20) + 36 + 4;
    self.localRender.frame = CGRectMake(0, anchorInfoBottom + 24, kScreenWidth / 2.0, kScreenWidth / 2.0 * 1280 / 720.0);
    self.remoteRender.frame = CGRectMake(self.localRender.right, self.localRender.top, self.localRender.width, self.localRender.height);
    self.singleRender.frame = self.view.bounds;
    
    [self.view sendSubviewToBack:self.singleRender];
    [self.view sendSubviewToBack:self.remoteRender];
    [self.view sendSubviewToBack:self.localRender];
}

/// 预览布局
- (void)layoutPreview
{
    [self.anchorInfo removeFromSuperview];
    [self.audienceInfo removeFromSuperview];
    [self.chatView removeFromSuperview];
    [self.pkBtn removeFromSuperview];
    [self.livingInputTool removeFromSuperview];
    [self.pkSuccessIco removeFromSuperview];
    [self.pkFailedIco removeFromSuperview];
    [self.inviteeInfo removeFromSuperview];
    
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.switchCameraBtn];
    [self.view addSubview:self.settingPanel];
    [self.view addSubview:self.bottomPanel];
    [self.view addSubview:self.warnToast];

    self.backBtn.frame = CGRectMake(20, (kIsFullScreen ? 44 : 20) + 8, 24, 24);
    self.switchCameraBtn.frame = CGRectMake(kScreenWidth - 20 - 24, (kIsFullScreen ? 44 : 20) + 8, 24, 24);
    self.settingPanel.frame = CGRectMake(20, (kIsFullScreen ? 88 : 64) + 20, kScreenWidth - 40, 88);
    self.bottomPanel.frame = CGRectMake(0, kScreenHeight - 128 - (kIsFullScreen ? 54 : 20), kScreenWidth, 128);
    self.warnToast.frame = CGRectMake(20, self.bottomPanel.top - 20 - 60, kScreenWidth - 40, 60);

    @weakify(self);
    self.warnToast.clickBlock = ^{
        @strongify(self);
        [self.warnToast removeFromSuperview];
    };
}

/// 单人直播布局
- (void)layoutSingleLive
{
    [self.pkStatusBar removeFromSuperview];
    [self.backBtn removeFromSuperview];
    [self.switchCameraBtn removeFromSuperview];
    [self.settingPanel removeFromSuperview];
    [self.bottomPanel removeFromSuperview];
    [self.pkSuccessIco removeFromSuperview];
    [self.pkFailedIco removeFromSuperview];
    [self.inviteeInfo removeFromSuperview];
    
    [self.view addSubview:self.anchorInfo];
    [self.view addSubview:self.audienceInfo];
    [self.view addSubview:self.chatView];
    [self.view addSubview:self.pkBtn];
    [self.view addSubview:self.livingInputTool];
    [self.view addSubview:self.toolBar];
    
    self.singleRender.hidden = NO;

    self.anchorInfo.frame = CGRectMake(8, (kIsFullScreen ? 44 : 20) + 4, 124, 36);
    self.audienceInfo.frame = CGRectMake(kScreenWidth - 8 - 195, self.anchorInfo.top + (36 - 28) / 2.0, 195, 28);
    CGFloat chatViewHeight = [self chatViewHeight];
    self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - chatViewHeight, kScreenWidth - 16 - 60 - 20, chatViewHeight);
    self.pkBtn.frame = CGRectMake(kScreenWidth - 60 - 8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - 60, 60, 60);
    self.livingInputTool.frame = CGRectMake(0, kScreenHeight - (kIsFullScreen ? 34 : 0) - 14 - 36, kScreenWidth, 36);
}

////多人连麦布局
//- (void)layoutConnectMic {
//    
//}

/// pk直播布局
- (void)layoutPkLive
{
    [self.backBtn removeFromSuperview];
    [self.switchCameraBtn removeFromSuperview];
    [self.settingPanel removeFromSuperview];
    [self.bottomPanel removeFromSuperview];
    [self.pkSuccessIco removeFromSuperview];
    [self.pkFailedIco removeFromSuperview];
    
    [self.view addSubview:self.pkStatusBar];
    [self.view addSubview:self.anchorInfo];
    [self.view addSubview:self.audienceInfo];
    [self.view addSubview:self.chatView];
    [self.view addSubview:self.pkBtn];
    [self.view addSubview:self.livingInputTool];
    [self.view addSubview:self.inviteeInfo];
    [self.view addSubview:self.toolBar];
    
    self.singleRender.hidden = YES;
    
    self.pkStatusBar.frame = CGRectMake(0, self.localRender.bottom, kScreenWidth, 58);
    self.anchorInfo.frame = CGRectMake(8, (kIsFullScreen ? 44 : 20) + 4, 124, 36);
    self.audienceInfo.frame = CGRectMake(kScreenWidth - 8 - 195, self.anchorInfo.top + (36 - 28) / 2.0, 195, 28);
    CGFloat chatViewHeight = [self chatViewHeight];
    self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - chatViewHeight, kScreenWidth - 16 - 60 - 20, chatViewHeight);
    self.pkBtn.frame = CGRectMake(kScreenWidth - 60 - 8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - 60, 60, 60);
    self.livingInputTool.frame = CGRectMake(0, kScreenHeight - (kIsFullScreen ? 34 : 0) - 14 - 36, kScreenWidth, 36);
    self.inviteeInfo.frame = CGRectMake(self.remoteRender.right - 8 - 82, self.remoteRender.top + 8, 82, 24);
    
    [self.pkStatusBar refreshWithLeftRewardCoins:0 leftRewardAvatars:@[] rightRewardCoins:0 rightRewardAvatars:@[]];
}

/// 初始化RTC引擎
- (void)setupRTCEngine
{
    NSAssert(![kAppKey isEqualToString:@"AppKey"], @"请设置AppKey");
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    
    // 设置直播模式
    [coreEngine setChannelProfile:kNERtcChannelProfileLiveBroadcasting];
    
    // 打开推流,回调摄像头采集数据
    NSDictionary *params = @{
        kNERtcKeyPublishSelfStreamEnabled: @YES,    // 打开推流
        kNERtcKeyVideoCaptureObserverEnabled: @YES  // 将摄像头采集的数据回调给用户
    };
    [coreEngine setParameters:params];
    [coreEngine setClientRole:kNERtcClientRoleBroadcaster];
    
    // 设置视频发送配置(帧率/分辨率)
    NERtcVideoEncodeConfiguration *config = [NETSLiveConfig shared].videoConfig;
    [coreEngine setLocalVideoConfig:config];
    
    // 设置音频质量
    NSUInteger quality = [NETSLiveConfig shared].audioQuality;
    [coreEngine setAudioProfile:kNERtcAudioProfileHighQuality scenario:quality];
    [coreEngine setChannelProfile:kNERtcChannelProfileLiveBroadcasting];
    
    NERtcEngineContext *context = [[NERtcEngineContext alloc] init];
    context.engineDelegate = self;
    context.appKey = kNertcAppkey;
    
    NERtcLogSetting *setting = [[NERtcLogSetting alloc] init];
     #if DEBUG
          setting.logLevel = kNERtcLogLevelInfo;
     #else
          setting.logLevel = kNERtcLogLevelWarning;
     #endif
     context.logSetting = setting;
    int res = [coreEngine setupEngineWithContext:context];
    YXAlogInfo(@"初始化设置 NERtcEngine, res: %d", res);
    
    // 启用本地音/视频
    [coreEngine enableLocalAudio:YES];
    [coreEngine enableLocalVideo:YES];
}

- (void)clickAction:(UIButton *)sender
{
    if (sender == self.backBtn) {
        [self _closeLiveRoom];
    }
    else if (sender == self.switchCameraBtn) {
        int res = [[NERtcEngine sharedEngine] switchCamera];
        YXAlogInfo(@"切换前后摄像头, res: %d", res);
    }else if (sender == self.pkBtn) {
        if (self.pkService.liveStatus == NETSPkServiceSingleLive) {
            if ([self.pkStatusBar superview]) {
                [NETSToast showToast:@"您已经再邀请中,不可再邀请"];
                return;
            }
            YXAlogInfo(@"打开pk列表面板,开始pk");
            [NETSChoosePKSheet showWithTarget:self];
        }else if (self.pkService.liveStatus == NETSPkServicePkLive) {
            YXAlogInfo(@"点击结束pk");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结束PK" message:@"PK尚未结束,强制结束会返回普通直播模式" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                YXAlogInfo(@"取消强制结束pk");
            }];
            @weakify(self);
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"立即结束" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [NETSToast showLoading];
                @strongify(self);
                [self _manualEndPk];
            }];
            [alert addAction:cancel];
            [alert addAction:confirm];
            [self presenAlert:alert];
        }
        else {
            YXAlogInfo(@"正在pk链接中,pk按钮无响应");
        }
    }
}

/// 强制关闭pk
- (void)_manualEndPk
{
    [self.pkStatusBar stopCountdown];
    @weakify(self);
    [self.pkService endPkWithCompletionBlock:^(NSError * _Nullable error) {
        YXAlogInfo(@"强制结束pk完成, error: %@", error);
        if (!error) {
            ntes_main_async_safe(^{
                @strongify(self);
                [NETSToast hideLoading];
                [self layoutSingleLive];
            });
        }
    }];
}

/// 关闭直播间
- (void)_closeLiveRoom
{
    // 重置service状态,避免leave channel触发代理方法
    self.pkService.liveStatus = NETSPkServiceInit;
    [NETSToast showLoading];
    @weakify(self);
    [self.pkService endLiveWithCompletionBlock:^(NSError * _Nullable error) {
        @strongify(self);
        [NETSToast hideLoading];
        [self.pkStatusBar stopCountdown];
        [[NENavigator shared].navigationController popViewControllerAnimated:YES];
        YXAlogInfo(@"关闭直播间,退出直播间结果, error: %@", error);
    }];
    if (_requestConnectMicBar) {
        [_requestConnectMicBar dismiss];
    }
}

- (void)updateLocalConnecterArray:(NSArray *)serverArray {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NETSConnectMicMemberModel *member in serverArray) {
        [tempArray addObject:member.accountId];
    }
    self.connectMicUidArray = tempArray;
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability *currentReach = [note object];
    NSCParameterAssert([currentReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [currentReach currentReachabilityStatus];
    if (netStatus == NotReachable) {//断网
        YXAlogInfo(@"主播检测到断网");
        self.isBrokenNetwork = YES;
    }else {//有网络
        if (self.isBrokenNetwork) {
            [NETSLiveApi requestMicSeatsResultListWithRoomId:self.liveRoomModel.liveCid type:NETSUserStatusAlreadyOnWheat successBlock:^(NSDictionary * _Nonnull response) {
                NSArray *memberList = response[@"/data/seatList"];
                NSMutableArray *currentConnecterArray = [NSMutableArray arrayWithArray:self.connectMicArray];
                for (NETSConnectMicMemberModel *memberModel in memberList) {
                    if (![self.connectMicUidArray containsObject:memberModel.accountId]) {
                        [currentConnecterArray addObject:memberModel];
                    }
                }
                //刷新麦位人数
                if (![self.view.subviews containsObject:self.connectMicView]) {
                    [self.view addSubview:self.connectMicView];
                }
                [self.connectMicView reloadDataSource:currentConnecterArray];
                YXAlogInfo(@"请求连麦者列表成功,response = %@",response);
            } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
                YXAlogError(@"请求连麦者列表失败，error = %@",error.description);
            }];
        }
    }

}

#pragma mark - 当键盘事件

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = rect.size.height;
    CGFloat chatViewHeight = [self chatViewHeight];
    [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - chatViewHeight - keyboardHeight - 50, kScreenWidth - 16 - 60 - 20, chatViewHeight);
        self.toolBar.frame = CGRectMake(0, kScreenHeight - keyboardHeight - 50, kScreenWidth, 50);
    }];
    [self.view bringSubviewToFront:self.toolBar];

}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    CGFloat chatViewHeight = [self chatViewHeight];
    [UIView animateWithDuration:0.1 animations:^{
        self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - chatViewHeight, kScreenWidth - 16 - 60 - 20, chatViewHeight);
        self.toolBar.frame = CGRectMake(0, kScreenHeight + 50, kScreenWidth, 50);
    }];
}

#pragma mark - NETSAnchorBottomPanelDelegate 底部操作面板代理

- (void)clickBeautyBtn
{
    [NETSBeautySettingActionSheet showWithMask:NO];
}

- (void)clickFilterBtn
{
    [NETSFilterSettingActionSheet showWithMask:NO];
}

- (void)clickSettingBtn
{
    [NETSLiveSettingActionSheet show];
}

- (void)clickStartLiveBtn
{
    // 开启直播条件判断
    NSString *topic = [self.settingPanel getTopic];
    NSString *cover = [self.settingPanel getCover];
    if (isEmptyString(topic)) {
        [NETSToast showToast:@"直播间主题为空"];
        return;
    }
    if (isEmptyString(cover)) {
        [NETSToast showToast:@"直播间封面为空"];
        return;
    }
    
    [NETSToast showLoading];
    @weakify(self);
    [self.pkService startSingleLiveWithTopic:topic coverUrl:cover successBlock:^(NETSCreateLiveRoomModel *_Nonnull room, NERtcLiveStreamTaskInfo *_Nonnull task) {
        @strongify(self);
        [NETSToast hideLoading];
        self.warnToast.hidden = YES;
        self.chatHandle.roomId = room.chatRoomId;
        self.anchorMessageHandle.roomId = room.chatRoomId;
        self.liveRoomModel = room;
    } failedBlock:^(NSError * _Nonnull error) {
        @strongify(self);
        [NETSToast hideLoading];
        if ([error.domain isEqualToString:@"NIMLocalErrorDomain"] && error.code == 13) {
            NSString *msg = error.userInfo[NSLocalizedDescriptionKey] ?: @"IM登录失败";
            [NETSToast showToast:msg];
            
            self.pkService.liveStatus = NETSPkServiceInit;
            [NETSToast showLoading];
            [self.pkService endLiveWithCompletionBlock:^(NSError * _Nullable error) {
                [NETSToast hideLoading];
                ntes_main_async_safe(^{
                    NEMenuViewController *vc = [[NEMenuViewController alloc] init];
                    [[NENavigator shared].navigationController popToViewController:vc animated:YES];
                });
            }];
        } else {
            NSString *msg = error.userInfo[NSLocalizedDescriptionKey] ?: @"开启直播间失败";
            [NETSToast showToast:msg];
            YXAlogInfo(@"开启直播间失败, error: %@", error);
        }
    }];
}

#pragma mark - NETSMoreSettingActionSheetDelegate 点击更多设置代理

/// 开启/关闭 摄像头
- (void)didSelectCameraEnable:(BOOL)enable
{
    if (!enable) {
        [self.localCanvas resetCanvas];
    } else {
        [self.localCanvas setupCanvas];
    }
}

/// 关闭直播间
- (void)didSelectCloseLive
{
    [self _closeLiveRoom];
}

#pragma mark - NETSLiveChatViewHandleDelegate 聊天室代理

- (void)didShowMessages:(NSArray<NIMMessage *> *)messages
{
    [self.chatView addMessages:messages];
}

/// 进入或离开房间
- (void)didChatroomMember:(NIMChatroomNotificationMember *)member enter:(BOOL)enter sessionId:(NSString *)sessionId
{
    if (enter) {
        YXAlogInfo(@"[demo] user %@ enter room.", member.userId);
    } else {
        YXAlogInfo(@"[demo] user %@ leaved room.", member.userId);
    }
    // 是否主播离开
    NSString *chatRoomCreator = self.pkService.singleRoom.imAccid;
    if (self.pkService.liveStatus == NETSPkServicePkLive) {
        chatRoomCreator = self.pkService.pkRoom.imAccid;
    }
    if ([chatRoomCreator isEqualToString:member.userId]) {
        YXAlogInfo(@"聊天室创建者: \"%@\" %@房间", member.userId, (enter ? @"加入":@"离开"));
    } else {
        // 提示非聊天室创建者 加入/离开 消息
        NIMMessage *message = [[NIMMessage alloc] init];
        message.text = [NSString stringWithFormat:@"\"%@\" %@房间", member.nick, (enter ? @"加入":@"离开")];
        message.remoteExt = @{@"type":@(1)};
        [_chatView addMessages:@[message]];
    }
    
    // 聊天室信息成员变更
    NSString *roomId = self.pkService.singleRoom.chatRoomId;
    [NETSChatroomService fetchMembersRoomId:roomId limit:10 successBlock:^(NSArray<NIMChatroomMember *> * _Nullable members) {
        YXAlogInfo(@"members: %@", members);
        [self.audienceInfo reloadWithDatas:members];
    } failedBlock:^(NSError * _Nonnull error) {
        YXAlogInfo(@"主播端获取IM聊天室成员失败, error: %@", error);
    }];
    
    YXAlogInfo(@"didChatroomMember:%@ enter:%hhd creator:%@ sessionId:%@", member.userId, enter, chatRoomCreator, sessionId);
}

/// 房间关闭
- (void)didChatroomClosedWithRoomId:(NSString *)roomId {
    
//    [self.liveClosedMask installWithAvatar:self.liveRoomModel.avatar nickname:self.liveRoomModel.nickname];
//    [self.view addSubview:self.liveClosedMask];
    YXAlogInfo(@"主播房间关闭");
}

/// 收到文本消息
- (void)didReceivedTextMessage:(NIMMessage *)message
{
    NSArray *msgs = @[message];
    [self.chatView addMessages:msgs];
}

#pragma mark - NETSInputToolBarDelegate 底部工具条代理事件

- (void)clickInputToolBarAction:(NETSInputToolBarAction)action
{
    switch (action) {
        case NETSInputToolBarInput: {
            [self.toolBar becomeFirstResponse];
        }
            break;
        case NETSInputToolBarBeauty: {
            [NETSBeautySettingActionSheet show];
        }
            break;
        case NETSInputToolBarConnectRequest: {//主播连麦管理
            
            if (self.pkService.liveStatus == NETSPkServicePkInviting) {
                [NETSToast showToast:@"PK邀请中，不能操作连麦"];
                //预留
            }else if (self.pkService.liveStatus == NETSPkServicePkLive){
                [NETSToast showToast:@"PK中，不能操作连麦"];
            }else {
                if (_requestConnectMicBar) {
                    [self.requestConnectMicBar dismiss];
                }
                NETSRequestManageMainController *statusVc = [[NETSRequestManageMainController alloc] initWithRoomId:self.liveRoomModel.liveCid];
                NTESActionSheetNavigationController *nav = [[NTESActionSheetNavigationController alloc] initWithRootViewController:statusVc];
                nav.dismissOnTouchOutside = YES;
                [[NENavigator shared].navigationController presentViewController:nav animated:YES completion:nil];
            }
           
        }
            break;
        case NETSInputToolBarMusic: {
            [NETSAudioMixingActionSheet show];
        }
            break;
        case NETSInputToolBarMore: {
            NSArray *items = [NETSLiveConfig shared].moreSettings;
            [NETSMoreSettingActionSheet showWithTarget:self items:items];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - NETSInvitingBarDelegate 取消连麦代理

- (void)clickCancelInviting:(NETSInviteBarType)barType {
    
    if (barType == NETSInviteBarTypeConnectMic) {
        [self clickInputToolBarAction:NETSInputToolBarConnectRequest];
    }else {//默认是邀请pk直播的类型
        [self.pkService inviterSendCancelPkWithSuccessBlock:^{
            YXAlogInfo(@"取消pk邀请");
        } failedBlock:^(NSError * _Nonnull error) {
            YXAlogInfo(@"取消pk邀请失败, error: %@", error);
        }];
    }
}


#pragma mark - NETSChoosePKSheetDelegate 选择主播PK代理

- (void)choosePkOnSheet:(NETSChoosePKSheet *)sheet withRoom:(NETSLiveRoomModel *)room
{
    [sheet dismiss];
    
    @weakify(self);
    void (^successBlock)(NETSCreateLiveRoomModel * _Nonnull, NIMSignalingChannelDetailedInfo * _Nonnull) = ^(NETSCreateLiveRoomModel *pkRoom, NIMSignalingChannelDetailedInfo * _Nonnull info) {
        @strongify(self);
        NSString *title = [NSString stringWithFormat:@"邀请\"%@\"PK连线中...", room.nickname];
        self.pkInvitingBar = [NETSInvitingBar showInvitingWithTarget:self title:title];
    };
    
    void (^failedBlock)(NSError * _Nullable) = ^(NSError * _Nullable error) {
        NSString *msg = error.userInfo[NSLocalizedDescriptionKey] ?: @"邀请PK失败";
        [NETSToast showToast:msg];
    };
    
    NSString *msg = [NSString stringWithFormat:@"确定邀请\"%@\"进行PK?", room.nickname];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"邀请PK" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        YXAlogInfo(@"邀请者取消pk邀请...");
    }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        YXAlogInfo(@"邀请者确定邀请%@,进行pk...", room.nickname);
        [self.pkService inviterSendPkInviteWithInviteeRoom:room successBlock:successBlock failedBlock:failedBlock];
    }];
    [alert addAction:cancel];
    [alert addAction:confirm];
    [self presenAlert:alert];
}

#pragma mark - NERtcEngineDelegateEx G2音视频

- (void)onNERtcEngineVideoFrameCaptured:(CVPixelBufferRef)bufferRef rotation:(NERtcVideoRotationType)rotation
{
    [[NETSFUManger shared] renderItemsToPixelBuffer:bufferRef];
}

- (void)onNERtcEngineUserDidJoinWithUserID:(uint64_t)userID userName:(NSString *)userName
{
    NERtcVideoCanvas *canvas = [self setupRemoteCanvas];
    [NERtcEngine.sharedEngine setupRemoteVideoCanvas:canvas forUserID:userID];
}

- (void)onNERtcEngineUserVideoDidStartWithUserID:(uint64_t)userID videoProfile:(NERtcVideoProfileType)profile
{
    _remoteCanvas.subscribedVideo = YES;
    [NERtcEngine.sharedEngine subscribeRemoteVideo:YES forUserID:userID streamType:kNERtcRemoteVideoStreamTypeHigh];
}

- (void)onNERtcEngineUserDidLeaveWithUserID:(uint64_t)userID reason:(NERtcSessionLeaveReason)reason
{
    // 如果远端的人离开了，重置远端模型和UI
    if (userID == _remoteCanvas.uid) {
        [_remoteCanvas resetCanvas];
        _remoteCanvas = nil;
    }
}

/// 离开channel
- (void)onNERtcEngineDidLeaveChannelWithResult:(NERtcError)result
{
    if (result != kNERtcNoError) {
        YXAlogInfo(@"离开单人channel失败, error: %d", result);
        return;
    }
    
    // 离开channel,重置混音索引
    [NETSLiveConfig shared].mixingIdx = -1;
    
    @weakify(self);
    [self.pkService transformRoomWithSuccessBlock:^(NETSPkServiceStatus status, int64_t uid) {
        @strongify(self);
        YXAlogInfo(@"转换直播间模式: %zd", status);
        if (status == NETSPkServicePkLive) {
            NERtcVideoCanvas *canvas = [self setupLocalCanvas];
            [NERtcEngine.sharedEngine setupLocalVideoCanvas:canvas];

            [self.serverStartPkSubject sendNext:@""];
        } else {
            NERtcVideoCanvas *canvas = [self setupSingleCanvas];
            [NERtcEngine.sharedEngine setupLocalVideoCanvas:canvas];
        }
    } failedBlock:^(NSError * _Nonnull error) {
        YXAlogInfo(@"单人直播间/pk直播间 转换失败, error: %@", error);
    }];
}

- (void)onNERtcEngineDidDisconnectWithReason:(NERtcError)reason
{
    [NETSToast showToast:@"网络断开"];
    [self _closeLiveRoom];
}

/// 直播推流状态回调
- (void)onNERTCEngineLiveStreamState:(NERtcLiveStreamStateCode)state taskID:(NSString *)taskID url:(NSString *)url
{
    YXAlogInfo(@"直播推流状态回调, state: %ld, taskId: %@, url: %@", state, taskID, url);
    if (state == kNERtcLsStatePushFail) {
        [NETSPushStreamService removeStreamTask:taskID successBlock:^{
            [NETSPushStreamService addStreamTask:self.pkService.streamTask successBlock:^{
                YXAlogInfo(@"重新推流成功");
            } failedBlock:^(NSError * _Nonnull error, NSString *taskID) {
                YXAlogInfo(@"重新推流失败, taskID:%@, error: %@", taskID, error);
            }];
        } failedBlock:^(NSError * _Nonnull error) {
            YXAlogInfo(@"推流失败, 移除原推流ID: %@, 失败, error: %@", taskID, error);
            if (error) {
                [self _closeLiveRoom];
            }
        }];
    }
}

/// 音效播放结束回调
- (void)onAudioEffectFinished:(uint32_t)effectId
{
    NSDictionary *info = @{ @"effectId": @(effectId) };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNetsRtcEffectStopNoti object:nil userInfo:info];
}


/// 点击屏幕收起键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.toolBar resignFirstResponder];
    [self.livingInputTool resignFirstResponder];
    YXAlogDebug(@"accountId = %@",[NEAccount shared].userModel.accountId);

}

#pragma mark - NTESKeyboardToolbarDelegate 键盘顶部工具条代理

- (void)didToolBarSendText:(NSString *)text
{
    if (isEmptyString(text)) {
        [NETSToast showToast:@"所发消息为空"];
        return;
    }
    
    [self.livingInputTool resignFirstResponder];
    NSError *err = nil;
    [self.pkService sendMessageWithText:text errorPtr:&err];
    YXAlogInfo(@"主播端 发送文本消息, error: %@", err);
}

/// pk推流
- (void)_pushPkLiveStreamWithData:(NETSPassThroughHandlePkStartData *)data
{
    YXAlogInfo(@"开始推流...");
    NSString *logPtr = (self.pkService.liveRole == NETSPkServiceInviter) ? @"邀请者" : @"被邀请者";
    
    @weakify(self);
    [self.pkService pushPkStreamWithData:data successBlock:^{
        YXAlogInfo(@"%@添加推流任务成功", logPtr);
    } failedBlock:^(NSError * _Nonnull error, NSString * _Nullable taskID) {
        @strongify(self);
        YXAlogInfo(@"%@添加推流任务失败, error: %@, taskID: %@", logPtr, error, taskID);
        if (error) {
            [self _closeLiveRoom];
        }
    }];
}

#pragma mark - private method

- (void)presenAlert:(UIAlertController *)alert
{
    // 消除顶层视图
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    for (UIView *subview in topmostView.subviews) {
        [subview removeFromSuperview];
    }
    topmostView.userInteractionEnabled = NO;
    
    // 弹出alert
    if (self.pkAlert) {
        [self.pkAlert dismissViewControllerAnimated:NO completion:nil];
        self.pkAlert = nil;
    }
    [[NENavigator shared].navigationController presentViewController:alert animated:YES completion:nil];
    self.pkAlert = alert;
}

//更新推流任务
- (void)updateLiveStreamTask:(NERtcLiveStreamTaskInfo *)taskInfo{
    int ret = [NERtcEngine.sharedEngine updateLiveStreamTask:taskInfo
                                               compeltion:^(NSString * _Nonnull taskId, kNERtcLiveStreamError errorCode) {
    if (errorCode == 0) {
          //推流任务添加成功
        }else {
          //推流任务添加失败
            YXAlogError(@"推流任务添加失败");
        }
    }];
    if (ret != 0) {
      //更新失败
        YXAlogError(@"更新推流任务失败");
    }
}

- (void)updateStreamUserTrans:(uint64_t)uid {

    NERtcLiveStreamTaskInfo *taskInfo = [[NERtcLiveStreamTaskInfo alloc] init];
    taskInfo.taskID = self.pkService.streamTask.taskID;
    taskInfo.streamURL = self.pkService.streamTask.streamURL;
    taskInfo.lsMode = kNERtcLsModeVideo;
    CGFloat width = 720;
    CGFloat height = 1280;
    

    //设置整体布局
    NERtcLiveStreamLayout *streamLayout = [[NERtcLiveStreamLayout alloc] init];
    streamLayout.width = width;
    streamLayout.height = height;
    taskInfo.layout = streamLayout;
    
    NSMutableArray *usersArray = [NSMutableArray array];
    //设置主播布局
    if (self.liveRoomModel.avRoomUid) {
        NERtcLiveStreamUserTranscoding *userTranscoding = [[NERtcLiveStreamUserTranscoding alloc] init];
        userTranscoding.uid = self.liveRoomModel.avRoomUid.longLongValue;
        userTranscoding.audioPush = YES;
        userTranscoding.videoPush = YES;
        userTranscoding.width = width;
        userTranscoding.height = height;
        userTranscoding.adaption = kNERtcLsModeVideoScaleCropFill;
        [usersArray addObject:userTranscoding];
    }
    
    //设置连麦者布局
    for (int i = 0; i<self.connectMicArray.count; i ++) {
        NETSConnectMicMemberModel *memberModel = self.connectMicArray[i];
        NERtcLiveStreamUserTranscoding *userTranscoding = [[NERtcLiveStreamUserTranscoding alloc] init];
        userTranscoding.uid = memberModel.avRoomUid.longLongValue;
        userTranscoding.audioPush = YES;
        userTranscoding.videoPush = YES;
        userTranscoding.x = 575;
        userTranscoding.y = 200 + (170+12)*i;
        userTranscoding.width = 132;
        userTranscoding.height = 170;
        userTranscoding.adaption = kNERtcLsModeVideoScaleCropFill;
        [usersArray addObject:userTranscoding];
    }
    taskInfo.layout.users = usersArray;
    [self updateLiveStreamTask:taskInfo];//更新推流任务
}



#pragma mark - NETSPassThroughHandleDelegate 服务端透传信息代理

/// 开始pk直播
- (void)receivePassThrourhPkStartData:(NETSPassThroughHandlePkStartData *)data
{
    [self.joinedPkChannelSubject sendNext:data];
    
    // pk布局
    ntes_main_async_safe(^{
        [NETSToast hideLoading];
        [self layoutPkLive];
    });
    
    // 开始pk倒计时
    int32_t start = kPkLiveTotalTime - (int32_t)((data.currentTime - data.pkStartTime) / 1000);
    [self.pkStatusBar countdownWithSeconds:start prefix:@"PK "];
    [self.pkStatusBar refreshWithLeftRewardCoins:0 leftRewardAvatars:@[] rightRewardCoins:0 rightRewardAvatars:@[]];
    
    // 加载远端pk者信息
    YXAlogInfo(@"准备绘制远端主播信息...");
    if (self.pkService.liveRole == NETSPkServiceInviter) {
        YXAlogInfo(@"当前主播为pk邀请方,远端主播为pk被邀请方, inviteeAvatar: %@, inviteeNickname: %@", data.inviteeAvatar, data.inviteeNickname);
        [self.inviteeInfo reloadAvatar:data.inviteeAvatar nickname:data.inviteeNickname];
    }
    else if (self.pkService.liveRole == NETSPkServiceInvitee) {
        YXAlogInfo(@"当前主播为pk被邀请方,远端主播为pk邀请方, inviterAvatar: %@, inviterNickname: %@", data.inviterAvatar, data.inviterNickname);
        [self.inviteeInfo reloadAvatar:data.inviterAvatar nickname:data.inviterNickname];
    }
}

/// pk惩罚(惩罚阶段)
- (void)receivePassThrourhPunishStartData:(NETSPassThroughHandlePunishData *)data pkResult:(NETSPkResult)pkResult
{
    if (pkResult == NETSPkTieResult) {
        [self.pkStatusBar stopCountdown];
    } else {
        int32_t seconds = kPkLivePunishTotalTime - (int32_t)((data.currentTime - data.pkPulishmentTime) / 1000);
        [self.pkStatusBar countdownWithSeconds:seconds prefix:@"惩罚 "];
    }
}

/// 用户打赏
- (void)receivePassThrourhRewardData:(NETSPassThroughHandleRewardData *)data
                           rewardMsg:(NIMMessage *)rewardMsg
{
    // 如果打赏的是当前主播,向聊天室发送打赏消息
    if ([data.fromUserAvRoomUid isEqualToString:self.pkService.singleRoom.avRoomUid]) {
        [self.chatView addMessages:@[rewardMsg]];
    }
    
    // pk状态,更新pk状态栏
    if (self.pkService.liveStatus == NETSPkServicePkLive) {
        BOOL isInviter = (self.pkService.liveRole == NETSPkServiceInviter);
        int32_t leftReward = isInviter ? data.inviterRewardPKCoinTotal : data.inviteeRewardPKCoinTotal;
        NSArray *leftAvatars = isInviter ? data.rewardAvatars : data.inviteeRewardAvatars;
        int32_t rightReward = isInviter ? data.inviteeRewardPKCoinTotal : data.inviterRewardPKCoinTotal;
        NSArray *rightAvatars = isInviter ? data.inviteeRewardAvatars : data.rewardAvatars;
        [self.pkStatusBar refreshWithLeftRewardCoins:leftReward leftRewardAvatars:leftAvatars rightRewardCoins:rightReward rightRewardAvatars:rightAvatars];
    }
    
    // 更新用户信息栏(云币值)
    int32_t coins = data.rewardCoinTotal;
    if (self.pkService.liveRole == NETSPkServiceInvitee) {
        coins = data.inviteeRewardCoinTotal;
    }
    [self.anchorInfo updateCoins:coins];
}

/// pk结束
- (void)receivePassThrourhPkEndData:(NETSPassThroughHandlePkEndData *)data
{
    
    // 停止pk计时
    [self.pkStatusBar stopCountdown];
    
    // 布局单人直播
    ntes_main_async_safe(^{
        [NETSToast hideLoading];
        [self layoutSingleLive];
    });
    
    // 若是自动结束,不提示
    if (isEmptyString(data.closedNickname)) {
        return;
    }
    
    // 若是当前用户取消,不提示
    NSString *nickname = [NEAccount shared].userModel.nickname;
    if ([data.closedNickname isEqualToString:nickname]) {
        return;
    }
    NSString *msg = [NSString stringWithFormat:@"%@结束PK", data.closedNickname];
    [NETSToast showToast:msg];
    
    if (self.pkAlert) {
        [self.pkAlert dismissViewControllerAnimated:YES completion:nil];
    }
}

/// 开始直播
- (void)receivePassThrourhLiveStartData:(NETSPassThroughHandleStartLiveData *)data
{
    // 服务端透传开始直播消息, 保持屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    // 单人直播布局
    ntes_main_async_safe(^{
        [NETSToast hideLoading];
        [self layoutSingleLive];
    });
}

//观众申请连麦
- (void)receivePassThrourhApplyJoinSeatsData:(NETSConnectMicModel *)data {
    
    // 消除顶层视图
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    for (UIView *subview in topmostView.subviews) {
        [subview removeFromSuperview];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationName_Audience_ApplyConnectMic object:nil userInfo:@{@"isDisPlay":@YES}];
    [self.requestConnectMicBar dismiss];
    self.requestConnectMicBar = [NETSInvitingBar showInvitingWithTarget:self title:@"收到新的连麦申请" barType:NETSInviteBarTypeConnectMic];
    
}


#pragma mark - NETSPkServiceDelegate pk服务类代理

/// 直播状态变更
- (void)didPkServiceChangedStatus:(NETSPkServiceStatus)status
{
    YXAlogInfo(@"主播端 直播状态变更, status: %lu", (unsigned long)status);
}

/// 获取到pk结果 代理方法
- (void)didPkServiceFetchedPkRestlt:(NETSPkResult)result
                              error:(NSError * _Nullable)error
{
    if (error) {
        YXAlogInfo(@"获取pk结果失败, error: %@", error);
        return;
    }
    
    CGRect leftIcoFrame = CGRectMake((self.localRender.width - 100) * 0.5, self.localRender.bottom - 100, 100, 100);
    CGRect rightIcoFrame = CGRectMake(self.remoteRender.left + (self.remoteRender.width - 100) * 0.5, self.remoteRender.bottom - 100, 100, 100);
    
    self.pkSuccessIco.image = [UIImage imageNamed:@"pk_succeed_ico"];
    self.pkFailedIco.image = [UIImage imageNamed:@"pk_failed_ico"];
    
    switch (result) {
        case NETSPkCurrentAnchorWin:
        {
            self.pkSuccessIco.frame = leftIcoFrame;
            self.pkFailedIco.frame = rightIcoFrame;
        }
            break;
        case NETSPkOtherAnchorWin:
        {
            self.pkSuccessIco.frame = rightIcoFrame;
            self.pkFailedIco.frame = leftIcoFrame;
        }
            break;
        case NETSPkTieResult:
        {
            self.pkSuccessIco.image = [UIImage imageNamed:@"pk_tie_ico"];
            self.pkFailedIco.image = [UIImage imageNamed:@"pk_tie_ico"];
            
            self.pkSuccessIco.frame = leftIcoFrame;
            self.pkFailedIco.frame = rightIcoFrame;
        }
            break;
            
        default:
            break;
    }
    
    [self.view addSubview:self.pkSuccessIco];
    [self.view addSubview:self.pkFailedIco];
}

/// PK链接操作超时
- (void)didPkServiceTimeoutForRole:(NETSPkServiceRole)role
{
    if (role == NETSPkServiceInviter) {
        YXAlogInfo(@"邀请者 PK链接超时...");
    }
    else if (role == NETSPkServiceInvitee) {
        YXAlogInfo(@"被邀请者 PK链接超时...");
    }
    ntes_main_async_safe(^{
        [NETSToast hideLoading];
        [NETSToast showToast:@"PK链接超时,已自动取消"];
        if ([self.pkInvitingBar superview]) {
            [self.pkInvitingBar dismiss];
        }
        if (self.pkAlert) {
            [self.pkAlert dismissViewControllerAnimated:NO completion:nil];
            self.pkAlert = nil;
        }
    });
}

#pragma mark - NETSPkInviterDelegate 邀请者代理

/// 邀请者 收到 被邀请者发出的 pk同步信息
- (void)inviterReceivedPkStatusSyncFromInviteeImAccId:(NSString *)inviteeImAccId
{
    
}

/// 邀请者 收到 被邀请者发出的 拒绝pk信息
- (void)inviterReceivedPkRejectFromInviteeImAccId:(NSString *)inviteeImAccId
                                       rejectType:(NETSPkRejectedType)rejectType
{
    YXAlogInfo(@"被邀请方拒绝邀请方pk邀请");
    [self.pkInvitingBar dismiss];
    NSString *msg = @"对方已拒绝你的PK邀请";
    if (rejectType == NETSPkRejectedForBusyInvitee) {
        msg = @"对方正在PK中,请稍后...";
    }
    [NETSToast showToast:msg];
}

/// 邀请方 收到 被邀请者发出的 接受PK邀请 信令
- (void)inviterReceivedPkAcceptFromInviteeImAccId:(NSString *)inviteeImAccId
{
    [self.pkInvitingBar dismiss];
    [NETSToast showLoading];
}

#pragma mark - NETSPkInviteeDelegate 被邀请者代理

/// 被邀请者 接受 邀请者 邀请
- (void)inviteeReceivedPkInviteByInviter:(NSString *)inviterNickname
                          inviterImAccId:(NSString *)inviterImAccId
                               pkLiveCid:(NSString *)pkLiveCid
{
    @weakify(self);
    void (^cancelBlock)(NSString * _Nonnull, NSString * _Nonnull) = ^(NSString *inviterNickname, NSString *pkLiveCid) {
        @strongify(self);
        YXAlogInfo(@"拒绝PK邀请, from: %@, pkLiveCid: %@", inviterNickname, pkLiveCid);
        [self.pkService inviteeSendRejectPkWithSuccessBlock:^{
            YXAlogInfo(@"被邀请者发送拒绝pk邀请信令成功");
        } failedBlock:^(NSError * _Nonnull error) {
            YXAlogInfo(@"被邀请者发送拒绝pk邀请信令失败, error: %@", error);
        }];
    };
    
    void (^confirmBlock)(NSString * _Nonnull, NSString * _Nonnull) = ^(NSString *inviterNickname, NSString *pkLiveCid) {
        @strongify(self);
        YXAlogInfo(@"接受PK邀请, from: %@, pkLiveCid: %@", inviterNickname, pkLiveCid);
        [NETSToast showLoading];
        [self.pkService inviteeSendAcceptPkWithLiveCid:pkLiveCid successBlock:^ {
//            [NETSToast hideLoading];
            int res = [[NERtcEngine sharedEngine] leaveChannel];
            YXAlogInfo(@"被邀请者离开单人直播间channel, res: %d", res);
        } failedBlock:^(NSError * _Nonnull error) {
            [NETSToast hideLoading];
            YXAlogInfo(@"被邀请者请求加入pk直播间失败, error: %@", error);
        }];
    };
    
    if (self.presentedViewController && [self.presentedViewController isKindOfClass:[NTESActionSheetNavigationController class]]) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    
    NSString *msg = [NSString stringWithFormat:@"\"%@\"邀请你进行PK,是否接受?", inviterNickname];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"邀请PK" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (cancelBlock) { cancelBlock(inviterNickname, pkLiveCid); }
    }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"接受" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (confirmBlock) { confirmBlock(inviterNickname, pkLiveCid); }
    }];
    [alert addAction:cancel];
    [alert addAction:confirm];
    [self presenAlert:alert];
}

/// 被邀请方 收到 邀请方 取消PK邀请 信令
- (void)inviteeReceivedCancelPkInviteResponse:(NIMSignalingCancelInviteNotifyInfo *)response
{
    [NETSToast showToast:@"对方已取消PK邀请"];
    if (self.pkAlert) {
        [self.pkAlert dismissViewControllerAnimated:YES completion:nil];
        self.pkAlert = nil;
    }
}

#pragma mark - NETSAnchorChatroomMessageHandleDelegate
// 观众成功上麦的聊天室消息
- (void)receivedAudienceConnectMicSuccess:(NETSConnectMicAttachment *)msgAttachment {
    
    [NETSLiveApi requestMicSeatsResultListWithRoomId:self.liveRoomModel.liveCid type:NETSUserStatusAlreadyOnWheat successBlock:^(NSDictionary * _Nonnull response) {
        self.connectMicArray = response[@"/data/seatList"];
        [self updateLocalConnecterArray:self.connectMicArray];
        ntes_main_async_safe(^{
            NIMMessage *message = [[NIMMessage alloc] init];
            message.text = [NSString stringWithFormat:@"\"%@\" 成功上麦", msgAttachment.member.nickName];
            message.remoteExt = @{@"type":@(1)};
            [self.chatView addMessages:@[message]];
            [NETSToast hideLoading];
            [self.view addSubview:self.connectMicView];
            [self.connectMicView reloadDataSource:self.connectMicArray];
            self.pkBtn.hidden = YES;
        });
        [self updateStreamUserTrans:[msgAttachment.member.avRoomUid longLongValue]];
        YXAlogInfo(@"请求连麦管理列表失败,response = %@",response);
    } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        YXAlogError(@"请求连麦管理列表失败，error = %@",error.description);
    }];
}

// 观众成功下麦的聊天室消息
- (void)receivedAudienceLeaveMicSuccess:(NETSConnectMicAttachment *)msgAttachment {

    [NETSLiveApi requestMicSeatsResultListWithRoomId:self.liveRoomModel.liveCid type:NETSUserStatusAlreadyOnWheat successBlock:^(NSDictionary * _Nonnull response) {
        self.connectMicArray = response[@"/data/seatList"];
        [self updateLocalConnecterArray:self.connectMicArray];
        if (self.connectMicArray.count > 0) {
            [self.connectMicView reloadDataSource:self.connectMicArray];
        }else {
            [self.connectMicView removeFromSuperview];
            self.connectMicView = nil;
            self.pkBtn.hidden = NO;
        }
        ntes_main_async_safe(^{
            NIMMessage *message = [[NIMMessage alloc] init];
            message.text = [NSString stringWithFormat:@"\"%@\" 成功下麦", msgAttachment.member.nickName];
            message.remoteExt = @{@"type":@(1)};
            [self.chatView addMessages:@[message]];
        });
        [self updateStreamUserTrans:[msgAttachment.member.avRoomUid longLongValue]];
        YXAlogInfo(@"请求连麦管理列表失败,response = %@",response);
    } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        YXAlogError(@"请求连麦管理列表失败，error = %@",error.description);
    }];
}

//主播收到印音视频变化的信息
- (void)receivedAudioAndVideoChange:(NETSConnectMicAttachment *)msgAttachment {
    for (NETSConnectMicMemberModel *memberModel in self.connectMicArray) {
        if ([msgAttachment.member.accountId isEqualToString:memberModel.accountId]) {
            memberModel.audio = msgAttachment.member.audio;
            memberModel.video = msgAttachment.member.video;
            break;
        }
    }
    [self.connectMicView reloadDataSource:self.connectMicArray];
}

#pragma mark - NETSMutiConnectViewDelegate
-(void)disconnectRoomWithUserId:(NSString *)userId {
    [NETSLiveApi requestSeatManagerWithRoomId:self.liveRoomModel.liveCid userId:userId index:1 action:NETSSeatsOperationAdminKickSeats successBlock:^(NSDictionary * _Nonnull response) {
        YXAlogDebug(@"管理员踢下麦成功,response = %@",response);
    } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        YXAlogError(@"管理员踢下麦失败，error = %@",error.description);
    }];
}

#pragma mark - lazy load

- (UIView *)singleRender
{
    if (!_singleRender) {
        _singleRender = [[UIView alloc] init];
    }
    return _singleRender;
}

- (UIView *)localRender
{
    if (!_localRender) {
        _localRender = [[UIView alloc] init];
    }
    return _localRender;
}

- (UIView *)remoteRender
{
    if (!_remoteRender) {
        _remoteRender = [[UIView alloc] init];
    }
    return _remoteRender;
}

- (NETSAnchorBottomPanel *)bottomPanel
{
    if (!_bottomPanel) {
        _bottomPanel = [[NETSAnchorBottomPanel alloc] init];
        _bottomPanel.delegate = self;
    }
    return _bottomPanel;
}

- (NTESKeyboardToolbarView *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[NTESKeyboardToolbarView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 50)];
        _toolBar.backgroundColor = UIColor.whiteColor;
        _toolBar.cusDelegate = self;
    }
    return _toolBar;
}

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn setImage:[UIImage imageNamed:@"back_ico"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton *)switchCameraBtn
{
    if (!_switchCameraBtn) {
        _switchCameraBtn = [[UIButton alloc] init];
        UIImage *img = [[UIImage imageNamed:@"switch_camera_ico"] sd_tintedImageWithColor:[UIColor whiteColor]];
        [_switchCameraBtn setImage:img forState:UIControlStateNormal];
        [_switchCameraBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraBtn;
}

- (NETSAnchorCoverSetting *)settingPanel
{
    if (!_settingPanel) {
        _settingPanel = [[NETSAnchorCoverSetting alloc] init];
    }
    return _settingPanel;
}

- (NETSWarnToast *)warnToast
{
    if (!_warnToast) {
        _warnToast = [[NETSWarnToast alloc] init];
        _warnToast.toast = @"本应用为测试产品、请勿商用。单次直播最长10分钟，每个频道最多10人";
    }
    return _warnToast;
}

- (NETSAnchorTopInfoView *)anchorInfo
{
    if (!_anchorInfo) {
        _anchorInfo = [[NETSAnchorTopInfoView alloc] init];
    }
    return _anchorInfo;
}

- (NETSAudienceNum *)audienceInfo
{
    if (!_audienceInfo) {
        _audienceInfo = [[NETSAudienceNum alloc] initWithFrame:CGRectZero];
    }
    return _audienceInfo;
}

- (NETSInputToolBar *)livingInputTool
{
    if (!_livingInputTool) {
        _livingInputTool = [[NETSInputToolBar alloc] init];
        _livingInputTool.delegate = self;
        _livingInputTool.textField.inputAccessoryView = [[UIView alloc] init];
    }
    return _livingInputTool;
}

- (UIButton *)pkBtn
{
    if (!_pkBtn) {
        _pkBtn = [[UIButton alloc] init];
        [_pkBtn setImage:[UIImage imageNamed:@"pk_ico"] forState:UIControlStateNormal];
        [_pkBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pkBtn;
}

- (NETSLiveChatView *)chatView {
    if (!_chatView) {
        CGRect frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - 204, kScreenWidth - 16 - 60 - 20, 204);
        _chatView = [[NETSLiveChatView alloc] initWithFrame:frame];
    }
    return _chatView;
}

- (CGFloat)chatViewHeight
{
    if (kScreenHeight <= 568) {
        return 100;
    } else if (kScreenHeight <= 736) {
        return 130;
    }
    return 204;
}

- (NETSPkStatusBar *)pkStatusBar
{
    if (!_pkStatusBar) {
        _pkStatusBar = [[NETSPkStatusBar alloc] init];
    }
    return _pkStatusBar;
}

- (UIImageView *)pkSuccessIco
{
    if (!_pkSuccessIco) {
        _pkSuccessIco = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    }
    return _pkSuccessIco;
}

- (UIImageView *)pkFailedIco
{
    if (!_pkFailedIco) {
        _pkFailedIco = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    }
    return _pkFailedIco;
}

- (NETSInviteeInfoView *)inviteeInfo
{
    if (!_inviteeInfo) {
        _inviteeInfo = [[NETSInviteeInfoView alloc] init];
    }
    return _inviteeInfo;
}

/// 建立单人直播canvas模型
- (NERtcVideoCanvas *)setupSingleCanvas
{
    if (!_singleCanvas) {
        _singleCanvas = [[NETSCanvasModel alloc] init];
        _singleCanvas.renderContainer = self.singleRender;
    }
    [_singleCanvas resetCanvas];
    return [_singleCanvas setupCanvas];
}

/// 建立本地canvas模型
- (NERtcVideoCanvas *)setupLocalCanvas
{
    if (!_localCanvas) {
        _localCanvas = [[NETSCanvasModel alloc] init];
        _localCanvas.renderContainer = self.localRender;
    }
    [_localCanvas resetCanvas];
    return [_localCanvas setupCanvas];
}

/// 建立远端canvas模型
- (NERtcVideoCanvas *)setupRemoteCanvas
{
    if (!_remoteCanvas) {
        _remoteCanvas = [[NETSCanvasModel alloc] init];
        _remoteCanvas.renderContainer = self.remoteRender;
    }
    [_remoteCanvas resetCanvas];
    return [_remoteCanvas setupCanvas];
}

- (NETSMutiConnectView *)connectMicView {
    if (!_connectMicView) {
        _connectMicView = [[NETSMutiConnectView alloc]initWithDataSource:self.connectMicArray frame:CGRectMake(kScreenWidth-88-10, 104, 88, kScreenHeight-2*104)];
        _connectMicView.roleType = NETSUserModeAnchor;
        _connectMicView.delegate = self;
    }
    return _connectMicView;
}

- (NETSAnchorChatroomMessageHandle *)anchorMessageHandle {
    if (!_anchorMessageHandle) {
        _anchorMessageHandle = [[NETSAnchorChatroomMessageHandle alloc]init];
        _anchorMessageHandle.delegate = self;
    }
    return _anchorMessageHandle;
}

//- (NETSLiveEndView *)liveClosedMask
//{
//    if (!_liveClosedMask) {
//        _liveClosedMask = [[NETSLiveEndView alloc] init];
//    }
//    return _liveClosedMask;
//}
@end
