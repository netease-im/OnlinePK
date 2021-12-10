//
//  NEAccount.m
//  NLiteAVDemo
//
//  Created by Think on 2020/8/26.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEAccount.h"
#import "NEAccountTask.h"
#import "NEService.h"
#import "NSDictionary+NTESJson.h"

/**
 账号行为监听对象
 */
@interface NEAccountObserverItem : NSObject

@property (nonatomic, weak)     id                      target;
@property (nonatomic, copy)     NEAccountActionBlock    actionBlock;
@property (nonatomic, assign)   NEAccountAction         action;

- (instancetype)initWithTarget:(id)target
                   actionBlock:(NEAccountActionBlock)actionBlock
                        action:(NEAccountAction)action;

@end

@implementation NEAccountObserverItem

- (instancetype)initWithTarget:(id)target
                   actionBlock:(NEAccountActionBlock)actionBlock
                        action:(NEAccountAction)action
{
    self = [super init];
    if (self) {
        _target = target;
        _actionBlock = actionBlock;
        _action = action;
    }
    return self;
}

@end

///

#define NEAccountShared [NEAccount shared]
#define kAccessTokenKey @"kAccessTokenKey"

@interface NEAccount ()

@property (nonatomic, readwrite, strong)    NSMutableArray      *actionObservers;
@property (nonatomic, readwrite, assign)    BOOL                hasLogin;
@property (nonatomic, readwrite, strong, nullable)  NEUser *userModel;
@property (nonatomic, readwrite, copy, nullable)    NSString    *accessToken;

@end

@implementation NEAccount

+ (instancetype)shared
{
    static NEAccount *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NEAccount alloc] init];
        instance.actionObservers = [NSMutableArray array];
        instance.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey];
    });
    return instance;
}

- (BOOL)hasLogin {
    return [[AuthorManager shareInstance] isLogin];
}

- (void)_notifyAccountAction:(NEAccountAction)action
{
    @synchronized (self.actionObservers) {
        NSMutableArray *validArr = [NSMutableArray array];
        for (int i = 0; i < [self.actionObservers count]; i++) {
            NEAccountObserverItem *observer = self.actionObservers[i];
            if (observer.target == nil) {
                [self.actionObservers removeObjectAtIndex:i];
                i--;
            } else if ((observer.action & action) && observer.actionBlock) {
                [validArr addObject:observer];
            }
        }
        for (NEAccountObserverItem *item in validArr) {
            if (item.target != nil) {
                item.actionBlock(action);
            }
        }
    }
}

@end

@implementation NEAccount (Observer)

+ (void)addObserverForObject:(_Nonnull id)object
                 actionBlock:(_Nonnull NEAccountActionBlock)actionBlock
{
    [self addObserverForObject:object action:NEAccountActionAll actionBlock:actionBlock];
}

+ (void)addObserverForObject:(_Nonnull id)object
                      action:(NEAccountAction)action
                 actionBlock:(_Nonnull NEAccountActionBlock)actionBlock
{
    NSAssert(object != nil, @"NEAccount - addObserverForObject: object cannot be nil");
    @synchronized (NEAccountShared.actionObservers) {
        for (int i = 0; i < [NEAccountShared.actionObservers count]; i++) {
            @autoreleasepool {
                NEAccountObserverItem *observer = NEAccountShared.actionObservers[i];
                if (observer.target == nil) {
                    [NEAccountShared.actionObservers removeObjectAtIndex:i];
                    i--;
                }
            }
        }
        NEAccountObserverItem *newObserver = [[NEAccountObserverItem alloc] initWithTarget:object actionBlock:actionBlock action:action];
        [NEAccountShared.actionObservers addObject:newObserver];
    }
}

+ (void)removeObserverForObject:(_Nonnull id)object
{
    NSAssert(object != nil, @"NEAccount - addObserverForObject: object cannot be nil");
    @synchronized (NEAccountShared.actionObservers) {
        for (int i = 0; i < [NEAccountShared.actionObservers count]; i++) {
            NEAccountObserverItem *observer = NEAccountShared.actionObservers[i];
            if (observer.target == nil || observer.target == object) {
                [NEAccountShared.actionObservers removeObjectAtIndex:i];
                i--;
            }
        }
    }
}

@end

@implementation NEAccount (Login)

+ (void)remoteLogoutWithCompletion:(_Nullable NEAccountComplete)completion
{
    NELogoutTask *task = [NELogoutTask taskWithSubURL:@"/auth/logout"];
    [[NEService shared] runTask:task completion:^(NSDictionary * _Nullable data, id  _Nullable task, NSError * _Nullable error) {
        if (error) {
            if (completion) { completion(nil, error); }
            return;
        }
        
        [self localLogoutWithCompletion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
            if (completion) { completion(data, nil); }
        }];
    }];
}

- (void)setHasLogin:(BOOL)hasLogin {
    _hasLogin = hasLogin;
}

- (BOOL)hasLogin {
    return _hasLogin;
}

+ (void)localLogoutWithCompletion:(_Nullable NEAccountComplete)completion
{
    NEAccountShared.hasLogin = NO;
    NEAccountShared.userModel = nil;
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kAccessTokenKey];
    NEAccountShared.accessToken = nil;
    [NEAccountShared _notifyAccountAction:NEAccountActionLogout];
    
    if (completion) {
        completion(nil, nil);
    }
}

+ (void)loginWithMobile:(NSString *)mobile
                smsCode:(NSString *)smsCode
             completion:(NEAccountComplete)completion
{
    NESmsLoginTask *task = [NESmsLoginTask taskWithSubURL:@"/auth/loginBySmsCode"];
    task.req_mobile = mobile;
    task.req_smsCode = smsCode;
    [[NEService shared] runTask:task completion:^(NSDictionary * _Nullable response, id  _Nullable task, NSError * _Nullable error) {
        [self _loginHandleWithResponse:response error:error completion:completion];
    }];
}

+ (void)loginByTokenWithCompletion:(_Nullable NEAccountComplete)completion
{
    NETokenLoginTask *task = [NETokenLoginTask taskWithSubURL:@"/auth/loginByToken"];
    [[NEService shared] runTask:task completion:^(NSDictionary * _Nullable response, id  _Nullable task, NSError * _Nullable error) {
        [self _loginHandleWithResponse:response error:error completion:completion];
    }];
}

+ (void)_loginHandleWithResponse:(NSDictionary *)response error:(NSError *)error completion:(_Nullable NEAccountComplete)completion {
    NSString *accessToken = nil;
    BOOL loginResult = NO;
    NSDictionary *data = response[@"data"];
    if (error == nil && data != nil && [[data jsonString:@"accessToken"] length] > 0) {
        accessToken = [data jsonString:@"accessToken"];
        loginResult = YES;
    }
    NEAccountShared.hasLogin = loginResult;
    NEAccountShared.userModel = loginResult ? [[NEUser alloc] initWithDictionary:data] : nil;
    NEAccountShared.accessToken = accessToken;
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kAccessTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (loginResult) {
        [NEAccountShared _notifyAccountAction:NEAccountActionLogin];
    }
    
    if (completion) {
        completion(response, error);
    }
}
+ (void)updateUserInfo:(NEUser *)user {
    NEAccountShared.userModel = user;
}

+ (void)imloginWithYXuser:(YXUserInfo *)yxUser {
    YXUserInfo *user = yxUser;
    [[[NIMSDK sharedSDK] loginManager] login:user.imAccid token:user.imToken completion:^(NSError * _Nullable error) {
        NSLog(@"login im error : %@", error);
        if (error) {
            [[[UIApplication sharedApplication] keyWindow] makeToast:error.description];
        }else{
            [NEAccount shared].accessToken = user.accessToken;
            NEUser *neuser = [NEUser yy_modelWithJSON:user.yy_modelToJSONObject];
            [NEAccount shared].userModel = neuser;
            [NEAccount shared].hasLogin = YES;
            [[[UIApplication sharedApplication] keyWindow] makeToast:@"IM登录成功"];
            [AuthorManager shareInstance].imLoginSuccess = YES;
        }
    }];
}

+ (void)syncLoginData:(YXUserInfo *)user {
    [NEAccount shared].accessToken = user.accessToken;
    NEUser *neuser = [NEUser yy_modelWithJSON:user.yy_modelToJSONObject];
    [NEAccount shared].userModel = neuser;
    [NEAccount shared].hasLogin = YES;
}

@end
