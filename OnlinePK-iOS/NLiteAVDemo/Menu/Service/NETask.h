//
//  NETask.h
//  NEDemo
//
//  Created by Think on 2020/8/26.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "NEServiceTask.h"
#import "NETask.h"
#import "AppKey.h"

NS_ASSUME_NONNULL_BEGIN

// 请求闭包
typedef void(^NERequestHandler)(NSDictionary * _Nullable data,id _Nullable task, NSError * _Nullable error);
static NSString *baseURL = kApiHost;
static NSString *baseDataURL = kApiDataHost;

@interface NETask : NSObject<NEServiceTask>
+ (instancetype)task;
+ (instancetype)taskWithSubURL:(NSString * __nullable)subURL;
+ (instancetype)taskWithURLString:(NSString *)urlString;
- (void)postWithCompletion:(NERequestHandler)completion;

@end

NS_ASSUME_NONNULL_END
