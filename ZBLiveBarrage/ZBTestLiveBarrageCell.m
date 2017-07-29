//
//  ZBTestLiveBarrageCell.m
//  ZBLiveBarrage
//
//  Created by zhangbao on 2017/3/15.
//  Copyright © 2017年 张宝. All rights reserved.
//

#import "ZBTestLiveBarrageCell.h"
#import "Masonry/Masonry.h"
#import "ZBTestModel.h"

#define kBarrageHeight 40

@interface ZBTestLiveBarrageCell()

@property (nonatomic, strong) UIImageView *headImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation ZBTestLiveBarrageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.layer.cornerRadius = kBarrageHeight * 0.5;
        
        [self addOwnViews];
        
        [self layoutFrameOfSubViews];
        
    }
    return self;
}

- (void)addOwnViews
{
    [self addSubview:self.headImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.textLabel];
}

- (void)layoutFrameOfSubViews
{
    [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.width.equalTo(_headImageView.mas_height);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headImageView.mas_right).offset(8);
        make.top.equalTo(self);
        make.bottom.equalTo(self.mas_centerY);
    }];
    
    [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameLabel);
        make.top.equalTo(_nameLabel.mas_bottom);
        make.bottom.right.equalTo(self);
    }];
}

- (void)setTestModel:(ZBTestModel *)testModel
{
    _testModel = testModel;
    
    _headImageView.image = [UIImage imageNamed:testModel.image];
    
    _nameLabel.text = testModel.name;
    
    _textLabel.text = testModel.text;
    
    NSDictionary *dictAttribute = @{NSFontAttributeName:_textLabel.font};
    CGRect rect = [_textLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, kBarrageHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:dictAttribute context:nil];
    
    self.barrageSize = CGSizeMake(rect.size.width + kBarrageHeight +20, kBarrageHeight);
}

- (UIImageView *)headImageView
{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.userInteractionEnabled = YES;
        _headImageView.layer.cornerRadius = kBarrageHeight * 0.5;
        _headImageView.layer.borderColor = [UIColor yellowColor].CGColor;
        _headImageView.layer.borderWidth = 1;
        _headImageView.clipsToBounds = YES;
    }
    return _headImageView;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor redColor];
        _nameLabel.font = [UIFont systemFontOfSize:14];
    }
    return _nameLabel;
}

- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont systemFontOfSize:16];
    }
    return _textLabel;
}

@end
