//
//  NETSAnchorBottomPanel.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/10.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSAnchorBottomPanel.h"
#import "UIControl+repeatclick.h"

@interface NETSCircleBtn ()

@property (nonatomic, strong)   UIImageView *iconView;
@property (nonatomic, strong)   UILabel     *titleLab;

@end

@implementation NETSCircleBtn

- (instancetype)initWithTitle:(NSString *)title
                         icon:(NSString *)icon;
{
    self = [super init];
    if (self) {
        self.layer.cornerRadius = 32;
        self.layer.masksToBounds = YES;
        [self addSubview:self.iconView];
        [self addSubview:self.titleLab];
        
        UIImage *image = [[UIImage imageNamed:icon] sd_tintedImageWithColor:[UIColor whiteColor]];
        self.iconView.image = image;
        self.titleLab.text = title;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, 64, 64);
    [super setFrame:newFrame];
    
    self.iconView.frame = CGRectMake((self.width - 24) / 2.0, 12, 24, 24);
    self.titleLab.frame = CGRectMake(0, 37, self.width, 20);
}

#pragma mark - lazy load

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
    }
    return _iconView;
}

- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:12];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

@end

///

@interface NETSAnchorBottomPanel ()

/// 开启直播间按钮
@property (nonatomic, strong)   UIButton    *liveBtn;
/// 开启直播间按钮 渐变图层
@property (nonatomic, strong)   CAGradientLayer *shadowLayer;
/// 美颜按钮
@property (nonatomic, strong)   NETSCircleBtn    *beautyBtn;
/// 滤镜按钮
@property (nonatomic, strong)   NETSCircleBtn    *filterBtn;


@end

@implementation NETSAnchorBottomPanel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    [self addSubview:self.beautyBtn];
    [self addSubview:self.filterBtn];
    [self addSubview:self.liveBtn];
    
    NSArray *views = @[self.beautyBtn, self.filterBtn];
    [views mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:64 leadSpacing:52 tailSpacing:52];
    for (UIView *view in views) {
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.height.mas_equalTo(64);
        }];
    }
    [self.liveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyBtn.mas_bottom).offset(20);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.height.mas_equalTo(44);
    }];
    [self.liveBtn.layer insertSublayer:self.shadowLayer atIndex:0];
}

- (void)clickAction:(UIButton *)sender
{
    if (self.delegate == nil) { return; }
    
    if ([sender isEqual:self.beautyBtn] && [self.delegate respondsToSelector:@selector(clickBeautyBtn)]) {
        [self.delegate clickBeautyBtn];
    }
    else if ([sender isEqual:self.filterBtn] && [self.delegate respondsToSelector:@selector(clickFilterBtn)]) {
        [self.delegate clickFilterBtn];
    }
    else if ([sender isEqual:self.liveBtn] && [self.delegate respondsToSelector:@selector(clickStartLiveBtn)]) {
        [self.delegate clickStartLiveBtn];
    }
}

#pragma mark - lazy load

- (NETSCircleBtn *)beautyBtn
{
    if (!_beautyBtn) {
        _beautyBtn = [[NETSCircleBtn alloc] initWithTitle:NSLocalizedString(@"美颜", nil) icon:@"beauty_ico"];
        _beautyBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [_beautyBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beautyBtn;
}

- (NETSCircleBtn *)filterBtn
{
    if (!_filterBtn) {
        _filterBtn = [[NETSCircleBtn alloc] initWithTitle:NSLocalizedString(@"滤镜", nil) icon:@"filter_ico"];
        _filterBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [_filterBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _filterBtn;
}


- (UIButton *)liveBtn
{
    if (!_liveBtn) {
        _liveBtn = [[UIButton alloc] init];
        [_liveBtn setTitle:NSLocalizedString(@"开启直播间", nil) forState:UIControlStateNormal];
        [_liveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_liveBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        _liveBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _liveBtn.layer.cornerRadius = 22;
        _liveBtn.layer.masksToBounds = YES;
        _liveBtn.ne_ignoreEvent = NO;
        _liveBtn.ne_acceptEventInterval = 3.0;//防重点击
    }
    return _liveBtn;
}

- (CAGradientLayer *)shadowLayer
{
    if (!_shadowLayer) {
        _shadowLayer = [CAGradientLayer layer];
        NSArray *colors = [NSArray arrayWithObjects:
                           (id)[HEXCOLOR(0x1ed0fd) CGColor],
                           (id)[HEXCOLOR(0x5561fc) CGColor],
                           nil
                           ];
        [_shadowLayer setColors:colors];
        [_shadowLayer setStartPoint:CGPointMake(0.0f, 0.0f)];
        [_shadowLayer setEndPoint:CGPointMake(1.0f, 0.0f)];
        CGFloat length = kScreenWidth - 20 * 2;
        [_shadowLayer setFrame:CGRectMake(0, 0, length, length)];
    }
    return _shadowLayer;
}

@end
