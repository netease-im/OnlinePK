//
//  NEFeedbackDemoVC.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/23.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEBaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEFeedbackDemoVC : NEBaseTableViewController
@property(strong,nonatomic)NSString *selectedDemo;
@property(copy,nonatomic)void(^didSelectDemo) (NSString *demo);

@end

NS_ASSUME_NONNULL_END
