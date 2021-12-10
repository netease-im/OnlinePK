//
//  NETSPkStatusBar.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/24.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NETSLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

///
/// PK状态条(固定高度58, 左侧为pk邀请者, 右侧为pk被邀请者)
///

@interface NETSPkStatusBar : UIView

/**
 刷新视图
 @param leftRewardCoins     - 左总打赏数量
 @param leftRewardAvatars   - 左打赏用户头像集合
 @param rightRewardCoins    - 右总打赏数量
 @param rightRewardAvatars  - 右打赏用户头像集合
 */
- (void)refreshWithLeftRewardCoins:(int64_t)leftRewardCoins
                 leftRewardAvatars:(nullable NSArray<NSString *> *)leftRewardAvatars
                  rightRewardCoins:(int64_t)rightRewardCoins
                rightRewardAvatars:(nullable NSArray<NSString *> *)rightRewardAvatars;

/**
 开始倒计时
 @param seconds         - 倒计时秒数
 @param prefix         - 显示前缀
 */
- (void)countdownWithSeconds:(int)seconds
                      prefix:(NSString *)prefix;

/// 停止计时器
- (void)stopCountdown;

@end

NS_ASSUME_NONNULL_END
