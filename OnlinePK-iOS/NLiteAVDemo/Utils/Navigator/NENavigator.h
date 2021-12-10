//
//  NENavigator.h
//  NLiteAVDemo
//
//  Created by Think on 2020/8/28.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NELoginOptions.h"

NS_ASSUME_NONNULL_BEGIN

@class NELiveRoomListDetailModel;

@interface NENavigator: NSObject

@property (nonatomic, weak) UINavigationController  *navigationController;
@property (nonatomic, weak) UINavigationController  *loginNavigationController;

+ (NENavigator *)shared;

/**
 展示登录控制器
 @param options - 登录配置项
 */
- (void)loginWithOptions:(NELoginOptions * _Nullable)options;

/**
 关闭登录视图
 @param completion - 关闭登录视图执行闭包
 */
- (void)closeLoginWithCompletion:(_Nullable NELoginBlock)completion;

/// 设置根控制器
- (void)setUpRootWindowCtrl;

/// 展示直播列表页
/// @param roomType 房间类型
- (void)showLiveListVCWithRoomType:(NERoomType)roomType;


/// 进入主播直播间
/// @param roomType 房间类型
- (void)showAnchorVCWithRoomType:(NERoomType)roomType;

/**
 进入直播间
 @param roomData 点击时候的数据源
 @param index 选中的房间
 */
- (void)showLivingRoom:(NSArray<NELiveRoomListDetailModel*> *)roomData selectindex:(NSInteger)index;

/**
 回到根tabBar控制器
 @param index   - 根导航控制器索引
 */
- (void)showRootNavWitnIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
