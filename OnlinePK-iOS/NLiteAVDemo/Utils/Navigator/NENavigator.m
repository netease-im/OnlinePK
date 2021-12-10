//
//  NENavigator.m
//  NLiteAVDemo
//
//  Created by Think on 2020/8/28.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.



#import "NTELoginVC.h"
#import "NETSLiveListVC.h"
#import "NETSAudienceCollectionViewVC.h"
#import "NEPkLiveViewController.h"
#import "NEPkConnectMicViewController.h"
#import "NETabbarController.h"

#import "NETSToast.h"

#import "NEAccount.h"
#import "NENavigator.h"
#import "NELiveRoomListModel.h"

@interface NENavigator ()

@end

@implementation NENavigator

+ (NENavigator *)shared
{
    static NENavigator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NENavigator alloc] init];
    });
    return instance;
}

- (void)loginWithOptions:(NELoginOptions * _Nullable)options
{
    if ([NEAccount shared].hasLogin) {
        return;
    }
    if (_loginNavigationController && _navigationController.presentingViewController == _loginNavigationController) {
        return;
    }
    NTELoginVC *loginVC = [[NTELoginVC alloc] initWithOptions:options];
    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    loginNav.navigationBar.barTintColor = [UIColor whiteColor];
    loginNav.navigationBar.translucent = NO;
    loginNav.modalPresentationStyle = UIModalPresentationFullScreen;
    __weak typeof(self) weakSelf = self;
    [_navigationController presentViewController:loginNav animated:YES completion:^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.loginNavigationController = loginNav;
    }];
}

- (void)closeLoginWithCompletion:(_Nullable NELoginBlock)completion
{
    if (_loginNavigationController.presentingViewController) {
        [_loginNavigationController dismissViewControllerAnimated:YES completion:completion];
    } else {
        if (_loginNavigationController.navigationController) {
            [_loginNavigationController.navigationController popViewControllerAnimated:NO];
        } else {
            [_loginNavigationController popViewControllerAnimated:NO];
        }
        if (completion) {
            completion();
        }
    }
}

- (void)setUpRootWindowCtrl {
    NETabbarController *tabBarVc = [[NETabbarController alloc]init];
    [NENavigator shared].navigationController = tabBarVc.menuNavController;
    [UIApplication sharedApplication].keyWindow.rootViewController = tabBarVc;
}

- (void)showLiveListVCWithRoomType:(NERoomType)roomType {
    NETSLiveListVC *vc = [[NETSLiveListVC alloc] initWithNavRoomType:roomType];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showAnchorVCWithRoomType:(NERoomType)roomType {
//    NETSAnchorVC *vc = [[NETSAnchorVC alloc] init];
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:YES];
    
    if (roomType == NERoomTypePkLive) {
        NEPkLiveViewController *ctrl = [[NEPkLiveViewController alloc]initWithRoomType:roomType];
        ctrl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:ctrl animated:YES];
    }else if(roomType == NERoomTypeConnectMicLive){
        NEPkConnectMicViewController *ctrl = [[NEPkConnectMicViewController alloc]initWithRoomType:roomType];
        ctrl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:ctrl animated:YES];
    }
}

- (void)showLivingRoom:(NSArray<NELiveRoomListDetailModel*> *)roomData selectindex:(NSInteger)index
{
    NETSAudienceCollectionViewVC *vc = [[NETSAudienceCollectionViewVC alloc]initWithScrollData:roomData currentRoom:index];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showRootNavWitnIndex:(NSInteger)index
{
    UITabBarController *tab = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    if (index >= [tab.viewControllers count]) {
        YXAlogInfo(@"索引越界");
    }
    for (UIViewController *vc in tab.viewControllers) {
        if (![vc isKindOfClass:[UINavigationController class]]) {
            continue;
        }
        UINavigationController *nav = (UINavigationController *)vc;
        [nav popToRootViewControllerAnimated:NO];
    }
    
    [tab setSelectedIndex:index];
    [UIApplication sharedApplication].delegate.window.rootViewController = tab;
    UINavigationController *nav = tab.viewControllers[index];
    self.navigationController = nav;
}

@end
