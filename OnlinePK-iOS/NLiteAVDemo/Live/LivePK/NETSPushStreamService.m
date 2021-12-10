//
//  NETSPushStreamService.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/15.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSPushStreamService.h"
#import <NERtcSDK/NERtcSDK.h>
#import "SKVObject.h"
#import "NSString+NTES.h"


@implementation NETSPushStreamService

+ (void)addStreamTask:(NERtcLiveStreamTaskInfo *)task
         successBlock:(void(^)(void))successBlock
          failedBlock:(void(^)(NSError *, NSString *))failedBlock
{
    int ret = [[NERtcEngine sharedEngine] addLiveStreamTask:task compeltion:^(NSString * _Nonnull taskId, kNERtcLiveStreamError errorCode) {
        if (errorCode == 0) {
            ApiLogInfo(@"添加推流任务成功, taskId: %@", taskId);
            if (successBlock) { successBlock(); }
        } else {
            ApiLogInfo(@"添加推流任务失败, taskId: %@, errorCode: %d", taskId, errorCode);
            if (failedBlock) {
                NSError *error = [NSError errorWithDomain:@"NETSRtcErrorDomain" code:errorCode userInfo:@{NSLocalizedDescriptionKey:  NSLocalizedString(@"推流失败", nil)}];
                failedBlock(error, taskId);
            }
        }
    }];
    if (ret != 0) {
        ApiLogInfo(@"添加推流任务失败, ret: %d", ret);
        if (failedBlock) {
            NSError *error = [NSError errorWithDomain:@"NETSRtcErrorDomain" code:ret userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"添加推流任务失败", nil)}];
            failedBlock(error, task.taskID);
        }
    }
}

+ (void)removeStreamTask:(NSString *)taskId
            successBlock:(void(^)(void))successBlock
             failedBlock:(void(^)(NSError *))failedBlock
{
    int ret = [[NERtcEngine sharedEngine] removeLiveStreamTask:taskId compeltion:^(NSString * _Nonnull taskId, kNERtcLiveStreamError errorCode) {
        if (errorCode == 0) {
            if (successBlock) { successBlock(); }
        } else {
            NSError *error = [NSError errorWithDomain:@"NETSRtcErrorDomain" code:errorCode userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"移除推流任务失败", nil)}];
            if (failedBlock) { failedBlock(error); }
        }
    }];
    if (ret != 0) {
        if (failedBlock) {
            NSError *error = [NSError errorWithDomain:@"NETSRtcErrorDomain" code:ret userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"移除推流任务失败", nil)}];
            failedBlock(error);
        }
    }
}

+ (nullable NERtcLiveStreamTaskInfo *)streamTaskWithUrl:(NSString *)url
                                                uids:(NSArray<NSNumber *> *)uids
                                           audioPush:(BOOL)audioPush
                                      otherAnchorUid:(int64_t)otherUid{
    if ([uids count] > 2 || [uids count] == 0) {
        ApiLogInfo(@"构建pushStreamTask失败: uid集合元素数量不符合预期");
        return nil;
    }
    
    BOOL isPking = ([uids count] == 2);
    
    NERtcLiveStreamTaskInfo *taskInfo = [[NERtcLiveStreamTaskInfo alloc] init];
    taskInfo.taskID = [NSString md5ForLower32Bate:url];
    taskInfo.streamURL = url;
    taskInfo.lsMode = kNERtcLsModeVideo;
    
    CGFloat width = 720;
    CGFloat height = isPking ? 640 : 1280;
    
    //设置整体布局
    NERtcLiveStreamLayout *streamLayout = [[NERtcLiveStreamLayout alloc] init];
    streamLayout.width = width;
    streamLayout.height = height;
    taskInfo.layout = streamLayout;
    
    NSArray *users = nil;
    if (isPking) {
        NERtcLiveStreamUserTranscoding *selfTranscoding = [self _streamUserTranscodingWithUid:[uids.firstObject longLongValue]
                                                                                        point:CGPointMake(0, 0)
                                                                                         size:CGSizeMake(360, 640)];
        NERtcLiveStreamUserTranscoding *otherTranscoding = [self _streamUserTranscodingWithUid:[uids.lastObject longLongValue]
                                                                                         point:CGPointMake(360, 0)
                                                                                          size:CGSizeMake(360, 640)];
        
        
        UInt64 firstUid = [uids.firstObject longLongValue];
        if (firstUid == otherUid) {
            selfTranscoding.audioPush = audioPush;
        }else{
            otherTranscoding.audioPush = audioPush;
        }
        users = @[selfTranscoding, otherTranscoding];
    }
    taskInfo.layout.users = users;
    return taskInfo;
}



+ (nullable NERtcLiveStreamTaskInfo *)streamTaskWithUrl:(NSString *)url
                                                   uids:(NSArray<NSNumber *> *)uids
{
    if ([uids count] > 2 || [uids count] == 0) {
        ApiLogInfo(@"构建pushStreamTask失败: uid集合元素数量不符合预期");
        return nil;
    }
    
    BOOL isPking = ([uids count] == 2);
    
    NERtcLiveStreamTaskInfo *taskInfo = [[NERtcLiveStreamTaskInfo alloc] init];
    taskInfo.taskID = [NSString md5ForLower32Bate:url];
    taskInfo.streamURL = url;
    taskInfo.lsMode = kNERtcLsModeVideo;
    
    CGFloat width = 720;
    CGFloat height = isPking ? 640 : 1280;
    
    //设置整体布局
    NERtcLiveStreamLayout *streamLayout = [[NERtcLiveStreamLayout alloc] init];
    streamLayout.width = width;
    streamLayout.height = height;
    taskInfo.layout = streamLayout;
    
    NSArray *users = nil;
    if (isPking) {
        NERtcLiveStreamUserTranscoding *selfTranscoding = [self _streamUserTranscodingWithUid:[uids.firstObject longLongValue]
                                                                                        point:CGPointMake(0, 0)
                                                                                         size:CGSizeMake(360, 640)];
        NERtcLiveStreamUserTranscoding *otherTranscoding = [self _streamUserTranscodingWithUid:[uids.lastObject longLongValue]
                                                                                         point:CGPointMake(360, 0)
                                                                                          size:CGSizeMake(360, 640)];

        users = @[selfTranscoding, otherTranscoding];
    } else {
        NERtcLiveStreamUserTranscoding *selfTranscoding = [self _streamUserTranscodingWithUid:[uids.firstObject longLongValue]
                                                                                        point:CGPointMake(0, 0)
                                                                                         size:CGSizeMake(width, height)];
        users = @[selfTranscoding];
    }
    taskInfo.layout.users = users;
    
    return taskInfo;
}

+ (NERtcLiveStreamUserTranscoding *)_streamUserTranscodingWithUid:(int64_t)uid point:(CGPoint)point size:(CGSize)size
{
    NERtcLiveStreamUserTranscoding *userTranscoding = [[NERtcLiveStreamUserTranscoding alloc] init];
    userTranscoding.uid = uid;
    userTranscoding.audioPush = YES;
    userTranscoding.videoPush = YES;
    userTranscoding.x = point.x;
    userTranscoding.y = point.y;
    userTranscoding.width = size.width;
    userTranscoding.height = size.height;
    userTranscoding.adaption = kNERtcLsModeVideoScaleCropFill;
    
    return userTranscoding;
}


//更新推流任务
+ (void)updateLiveStreamTask:(NERtcLiveStreamTaskInfo *)taskInfo
               successBlock:(void(^)(void))successBlock
                failedBlock:(void(^)(NSError *))failedBlock {
    
    int ret = [NERtcEngine.sharedEngine updateLiveStreamTask:taskInfo
                                               compeltion:^(NSString * _Nonnull taskId, kNERtcLiveStreamError errorCode) {
    if (errorCode == 0) {
        
        successBlock();
          //推流任务添加成功
        }else {
          //推流任务添加失败
            NSError *error = [NSError errorWithDomain:@"NETSRtcErrorDomain" code:errorCode userInfo:@{NSLocalizedDescriptionKey: @"updateLiveStream failed"}];
            failedBlock(error);
        }
    }];
    if (ret != 0) {
      //更新失败
        NSError *error = [NSError errorWithDomain:@"NETSRtcErrorDomain" code:ret userInfo:@{NSLocalizedDescriptionKey: @"updateLiveStream failed"}];
        failedBlock(error);
    }
}

+ (nullable SKVObject *)parseCutomInfoForResponse:(NIMSignalingNotifyInfo *)response
{
    NSString *jsonStr = response.customInfo;
    if (isEmptyString(jsonStr)) {
        ApiLogInfo(@"IM信令自定义信息字段为空");
        return nil;
    }
    
    SKVObject *obj = [SKVObject ofJSON:jsonStr];
    if (!obj) {
        ApiLogInfo(@"IM信令自定义信息解析失败");
        return nil;
    }
    return obj;
}

+ (void)joinChannelWithToken:(NSString *)token
                 channelName:(nullable NSString *)channelName
                         uid:(uint64_t)uid
                   streamUrl:(NSString *)streamUrl
                successBlcok:(void(^)(NERtcLiveStreamTaskInfo *))successBlcok
                 failedBlock:(void(^)(NSError *, NSString * _Nullable))failedBlock
{
    if (isEmptyString(streamUrl) || isEmptyString(token) || isEmptyString(channelName)) {
        if (failedBlock) {
            NSError *error = [NSError errorWithDomain:@"NETSPkLiveParamErrorDomain" code:1000 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"加入直播间并推流失败, 参数错误", nil)}];
            failedBlock(error, nil);
        }
        return;
    }
    
    int res = [NERtcEngine.sharedEngine joinChannelWithToken:token channelName:channelName myUid:uid completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd,uint64_t uid) {
        if (error) {
            if (failedBlock) { failedBlock(error, nil); }
        } else {
            NERtcLiveStreamTaskInfo *task = [NETSPushStreamService streamTaskWithUrl:streamUrl uids:@[@(uid)]];
            [NETSPushStreamService addStreamTask:task successBlock:^{
                if (successBlcok) { successBlcok(task); }
            } failedBlock:failedBlock];
        }
    }];
    
    if (res != 0) {
        if (failedBlock) {
            if (res == kNERtcErrInvalidState) {//30005是因为还未退出rtc导致的
                [NERtcEngine.sharedEngine leaveChannel];
            }
            NSError *error = [NSError errorWithDomain:@"NETSPkLiveParamErrorDomain" code:res userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"加入直播间失败", nil)}];
            failedBlock(error, nil);
        }
        return;
    }
}

@end
