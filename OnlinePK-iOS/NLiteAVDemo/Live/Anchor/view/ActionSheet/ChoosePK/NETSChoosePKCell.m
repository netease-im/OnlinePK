//
//  NETSChoosePKCell.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSChoosePKCell.h"
#import "NELiveRoomListModel.h"

@interface NETSChoosePKCell ()

@property (nonatomic, strong)   UIView      *topLine;
@property (nonatomic, strong)   UIImageView *avatar;
@property (nonatomic, strong)   UILabel     *nick;
@property (nonatomic, strong)   UILabel     *audience;
@property (nonatomic, strong)   UIButton    *pkBtn;
@property (nonatomic, strong)   NELiveRoomListDetailModel   *model;

@end

@implementation NETSChoosePKCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

///

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.topLine];
        [self.contentView addSubview:self.avatar];
        [self.contentView addSubview:self.nick];
        [self.contentView addSubview:self.audience];
        [self.contentView addSubview:self.pkBtn];
    }
    return self;
}

- (void)layoutSubviews
{
    self.topLine.frame = CGRectMake(20, 0, self.contentView.width - 40, 0.5);
    self.avatar.frame = CGRectMake(20, 8, 40, 40);
    self.nick.frame = CGRectMake(self.avatar.right + 12, 8, 100, 22);
    self.audience.frame = CGRectMake(self.nick.left, self.nick.bottom, self.nick.width, 18);
    self.pkBtn.frame = CGRectMake(self.contentView.width - 20 - 70, 14, 70, 28);
}

- (void)installWithModel:(NELiveRoomListDetailModel *)model indexPath:(NSIndexPath *)indexPath
{
    _model = model;
    
    self.topLine.hidden = (indexPath.row == 0);
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:model.anchor.avatar]];
    self.nick.text = model.anchor.nickname;
    int32_t num = MAX(0, model.live.audienceCount);
    self.audience.text = [NSString stringWithFormat:NSLocalizedString(@"观众数: %@", nil), kFormatNum(num)];
}

+ (NETSChoosePKCell *)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath datas:(NSArray <NELiveRoomListDetailModel *> *)datas
{
    NETSChoosePKCell *cell = [tableView dequeueReusableCellWithIdentifier:[NETSChoosePKCell description]];
    id model = nil;
    if ([datas count] > indexPath.row) {
        model = datas[indexPath.row];
    }
    [cell installWithModel:model indexPath:indexPath];
    return cell;
}

+ (CGFloat)height
{
    return 56;
}

- (void)pkBtnClick:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickPKModel:)]) {
        [self.delegate didClickPKModel:self.model];
    }
}

#pragma mark - lazy load

- (UIView *)topLine
{
    if (!_topLine) {
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = HEXCOLOR(0xd2d2d2);
    }
    return _topLine;
}

- (UIImageView *)avatar
{
    if (!_avatar) {
        _avatar = [[UIImageView alloc] init];
        _avatar.layer.cornerRadius = 20;
        _avatar.layer.masksToBounds = YES;
    }
    return _avatar;
}

- (UILabel *)nick
{
    if (!_nick) {
        _nick = [[UILabel alloc] init];
        _nick.font = [UIFont systemFontOfSize:14];
        _nick.textColor = HEXCOLOR(0x0F0C0A);
    }
    return _nick;
}

- (UILabel *)audience
{
    if (!_audience) {
        _audience = [[UILabel alloc] init];
        _audience.font = [UIFont systemFontOfSize:12];
        _audience.textColor = HEXCOLOR(0x999999);
    }
    return _audience;
}

- (UIButton *)pkBtn
{
    if (!_pkBtn) {
        _pkBtn = [[UIButton alloc] init];
        _pkBtn.layer.cornerRadius = 4;
        _pkBtn.layer.masksToBounds = YES;
        _pkBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_pkBtn setTitle:NSLocalizedString(@"发起PK", nil) forState:UIControlStateNormal];
        [_pkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_pkBtn addTarget:self action:@selector(pkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0, 0, 70, 28);
        gradientLayer.colors = @[(__bridge id)[HEXCOLOR(0xfa555f) colorWithAlphaComponent:1.0].CGColor,
                                 (__bridge id)[HEXCOLOR(0xd846f6) colorWithAlphaComponent:1.0].CGColor];
        gradientLayer.startPoint = CGPointMake(.0, .0);
        gradientLayer.endPoint = CGPointMake(1.0, 0.0);

        [_pkBtn.layer insertSublayer:gradientLayer atIndex:0];
    }
    return _pkBtn;
}

@end
