//
//  ViewController.m
//  ZBLiveBarrage
//
//  Created by zhangbao on 2017/3/15.
//  Copyright © 2017年 张宝. All rights reserved.
//

#import "ViewController.h"
#import "Masonry/Masonry.h"
#import "ZBLiveBarrage.h"
#import "ZBTestLiveBarrageCell.h"
#import "ZBTestModel.h"

@interface ViewController ()<ZBLiveBarrageDelegate>
{
    NSArray *_nameArray;
    NSArray *_textArray;
    NSArray *_imageArray;
}

@property (nonatomic, strong) ZBLiveBarrage *barrageView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化数据
    [self setUpData];
    
    [self.view addSubview:self.barrageView];
    
    [_barrageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(20);
        make.height.mas_equalTo(200);
    }];
    
    [_barrageView start];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 创建 模型
    ZBTestModel *model = [ZBTestModel new];
    model.image = _imageArray[rand()%_imageArray.count];
    model.name = _nameArray[rand()%_nameArray.count];
    model.text = _textArray[rand()%_textArray.count];
    
    // 创建弹幕
    ZBTestLiveBarrageCell *barrageCell = [ZBTestLiveBarrageCell new];
    // 给每条弹幕设置随机速度，实际应用中根据不同弹幕设置不同速度，也可固定值
    barrageCell.barrageShowDuration = [@[@3,@4,@5,@6][rand()%4] floatValue];
    // 弹幕延时消失
//    barrageCell.afterDelayExit = 3;
    // 延迟展示时间
//    barrageCell.barrageDelay = 1;
    // 弹道数
    barrageCell.channelCount = 4;
    // 距离上一条弹幕的距离，可固定值
    barrageCell.margin = 10;
    // 给弹幕 模型赋值
    barrageCell.testModel = model;
    
    // 插入跑到
    [_barrageView insertBarrages:@[barrageCell]];
    
}

- (void)dealloc
{
    [_barrageView stop];
}

- (void)setUpData
{
    _nameArray = @[@"2k小新", @"你美你媚", @"你是我的眼", @"天王", @"孙悟空", @"杜甫", @"隔壁老王", @"张三", @"一生有你"];
    
    _textArray = @[@"多少弹幕都不会重叠",@"随便什么样式",@"继承ZBLiveBarrageCell，各种样式随你定每一条弹幕的",@"每条的弹幕的速度都可以不相同",@"每条弹幕的Size可以不相同",@"代码简单易懂",@"直播弹幕LiveBarrage最懂你",@"解决你直播弹幕没有头绪的难题",@"请单击Star 666",@"动态改变弹道数"];
    
    _imageArray = @[@"image0.jpg", @"image1.jpg", @"image2.jpg", @"image3.jpg", @"image4.jpg", @"image5.jpg"];
}

#pragma mark - <ZBLiveBarrageDelegate>
- (void)zb_barrageView:(ZBLiveBarrage *)barrageView didSelectedCell:(ZBLiveBarrageCell *)cell
{
    ZBTestLiveBarrageCell *testCell = (ZBTestLiveBarrageCell *)cell;
    
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ 被点击了！！", testCell.testModel.name] message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
}

- (void)zb_barrageView:(ZBLiveBarrage *)barrageView willDisplayCell:(ZBLiveBarrageCell *)cell
{
    
}

#pragma mark - <Setter/Getter>
- (ZBLiveBarrage *)barrageView
{
    if (!_barrageView) {
        _barrageView = [[ZBLiveBarrage alloc] init];
        _barrageView.backgroundColor = [UIColor cyanColor];
        _barrageView.delegate = self;
    }
    return _barrageView;
}

@end
