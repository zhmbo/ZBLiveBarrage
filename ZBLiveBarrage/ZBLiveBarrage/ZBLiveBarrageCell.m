//
//  ZBLiveBarrageDescriptor.m
//  LiveBarrage
//
//  Created by 张宝 on 16/12/20.
//  Copyright © 2016年 张宝. All rights reserved.
//

#import "ZBLiveBarrageCell.h"

@interface ZBLiveBarrageCell()

/** 计时器用来获取 */
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) BOOL afterDelayAble;

@end

@implementation ZBLiveBarrageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        _barrageSize = CGSizeMake(200, 40);
        _barrageShowDuration = 3;
        _barrageDelay = 0;
        _afterDelayExit = 0;
        _model = nil;
        _channelCount = 3;
        _margin = 0;
        _status = EStatusOfBarrage_Stop;
        _afterDelayAble = NO;
        
    }
    return self;
}

// 实时监测当前frame
- (void)receiveFrameNewValue
{
    CGFloat barrageX = [[self.layer presentationLayer] frame].origin.x;
    CGFloat barrageWidth = self.frame.size.width;
    
    // 真实速度
    CGFloat speed = (self.superview.frame.size.width + barrageWidth) / self.barrageShowDuration;
    
    // 开始谢幕所需时间
    CGFloat beginExitTime = barrageWidth / speed;
    
    if (_afterDelayExit > 0) {
        // 当前为延时退出屏幕状态
        self.status = EStatusOfBarrage_AfterDelay;
        if (-0.5< barrageX < 0.5) {
            
            if (_afterDelayAble) { return;}
            _afterDelayAble = YES;
            [self pause];
            [self performSelector:@selector(resume) withObject:nil afterDelay:_afterDelayExit];
            [self performSelector:@selector(changeStatus) withObject:nil afterDelay:_afterDelayExit - beginExitTime];
        }
    }
}
- (void)changeStatus
{
    self.status = EStatusOfBarrage_Start;
}

- (void)startAnimations:(void(^)(void))animations completion:(void(^)(BOOL))completion
{
    self.status = EStatusOfBarrage_Start;
    
    _timer = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(receiveFrameNewValue) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    // 开始弹幕动画 UIViewAnimationOptionCurveLinear 匀速动画
    [UIView animateWithDuration:self.barrageShowDuration delay:self.barrageDelay options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction) animations:^{
        
        if (animations) {
            animations();
        }
        
    } completion:^(BOOL finished) {
        
        _status = EStatusOfBarrage_Start;
        
        if (completion) {
            completion(finished);
        }
        
        if(_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        
    }];
}

- (void)pause
{
    // 将当前时间CACurrentMediaTime转换为layer上的时间, 即将parent time转换为local time
    CFTimeInterval pauseTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    
    // 设置layer的timeOffset, 在继续操作也会使用到
    self.layer.timeOffset = pauseTime;
    
    // local time与parent time的比例为0, 意味着local time暂停了
    self.layer.speed = 0;
}

- (void)resume
{
    // 时间转换
    CFTimeInterval pauseTime = self.layer.timeOffset;
    // 计算暂停时间
    CFTimeInterval timeSincePause = CACurrentMediaTime() - pauseTime;
    // 取消
    self.layer.timeOffset = 0;
    // local time相对于parent time世界的beginTime
    self.layer.beginTime = timeSincePause;
    // 继续
    self.layer.speed = 1;
}


@end
