//
//  NETSLiveListVC.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/9.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 直播列表页 VC
///

@interface NETSLiveListVC : UIViewController



/// 构造方法
/// @param roomType 房间类型
- (instancetype)initWithNavRoomType:(NERoomType)roomType;

@end

NS_ASSUME_NONNULL_END
