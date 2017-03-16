//
//  ZBLiveBarrage.m
//  LiveBarrage
//
//  Created by 张宝 on 16/12/15.
//  Copyright © 2016年 张宝. All rights reserved.
//


#import "ZBLiveBarrage.h"

#define BARRAGE_WIDTH self.frame.size.width

@interface ZBLiveBarrage()

/** 轨道数组(存放弹幕用于弹幕碰撞检测) */
@property (nonatomic, strong) NSMutableArray                            *channelArray;

/** 数据源 */
@property (nonatomic, strong) NSMutableArray <ZBLiveBarrageCell *>      *dataArray;

/** 记录界面正在飞翔的弹幕 */
@property (strong, nonatomic) NSMutableArray <ZBLiveBarrageCell *>      *showBarrages;

/** 记录当前插入的models中剩余还没展示的消息数 */
@property (assign, nonatomic) NSInteger                                 count;

/** 当前弹幕状态 */
@property (nonatomic, assign) EStatusOfBarrage                          status;

/** 轨道数 */
@property (nonatomic, assign) NSInteger                                 channelCount;

/** 弹幕间隙 */
@property (nonatomic, assign) CGFloat                                   margin;

@end

@implementation ZBLiveBarrage

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.status = EStatusOfBarrage_Stop;
    }
    return self;
}

- (void)creatBarrage
{
    // 获取数据中第一条弹幕
    if (self.dataArray.firstObject) {
        
        // 创建弹幕
        ZBLiveBarrageCell *barrageView = self.dataArray.firstObject;
        
        barrageView.frame = CGRectMake(BARRAGE_WIDTH, 0, barrageView.barrageSize.width, barrageView.barrageSize.height);
        
        self.margin = barrageView.margin;
        
        self.channelCount = barrageView.channelCount;
        
        // 获取可用跑到
        NSInteger row = [self zb_canBarrageSendInTheChannel:barrageView];
        
        // 启动发射biubiubiu~~~
        if (row >= 0) {
            
            // 弹幕已启动立即删除数据，以免影响下一次获取数据值
            [self.dataArray removeObjectAtIndex:0];
            
            // 添加弹幕到视图
            if (![self.subviews containsObject:barrageView]) {
                [self addSubview:barrageView];
            }
            
            // 计算弹幕在哪里跑合适
            CGFloat barrageY = 0;
            
            if (row > 0) { // 若果不是第一条跑道
                
//                if ([_channelArray[row - 1] isKindOfClass:[ZBLiveBarrageCell class]]) {
                
                    ZBLiveBarrageCell *rowLastBarrage = (ZBLiveBarrageCell*)_channelArray[row-1];
                    
                    barrageY = CGRectGetMaxY(rowLastBarrage.frame) + barrageView.margin;
//                }
                
            }
            
            barrageView.frame = CGRectMake(BARRAGE_WIDTH,  barrageY, barrageView.barrageSize.width, barrageView.barrageSize.height);
            
            // 替换轨道上最后一条弹幕
            [_channelArray setObject:barrageView atIndexedSubscript:row];
            
            // 通知代理此弹幕将要显示
            if ([self.delegate respondsToSelector:@selector(zb_barrageView:willDisplayCell:)]) {
                [self.delegate zb_barrageView:self willDisplayCell:barrageView];
            }
            
            // 添加进飞翔弹幕队列
            [self.showBarrages addObject:barrageView];
            
            [barrageView startAnimations:^{
                
                // 从视图右侧进入左侧移除
                [barrageView setTransform:CGAffineTransformMakeTranslation(- barrageView.frame.size.width-BARRAGE_WIDTH, 0)];
                
            } completion:^(BOOL finished) {
                // 完成动画移除此条弹幕
                [barrageView removeFromSuperview];
                
                // 从飞翔弹幕队列移除
                [self.showBarrages removeObject:barrageView];
                
                // 通知代理此条弹幕已经 玩蛋去
                if ([self.delegate respondsToSelector:@selector(zb_barrageView:didEndDisplayingCell:)]) {
                    [self.delegate zb_barrageView:self didEndDisplayingCell:barrageView];
                }
                
                // 通知代理当前已经没有什么可以炫耀的了
                if (--self.count <= 0) {
                    if ([self.delegate respondsToSelector:@selector(zb_barrageViewCompletedCurrentAnimations)]) {
                        [self.delegate zb_barrageViewCompletedCurrentAnimations];
                    }
                    self.count = 0;
                }
                
//                NSLog(@"弹幕剩余 -- %ld条", self.count);

            }];
        }
    }
    
    // 再次执行 creatBarrage 方法
    [self performSelector:@selector(creatBarrage) withObject:nil afterDelay:0.1f];
}

#pragma mark - <Public-Method>
- (void)insertBarrages:(NSArray <ZBLiveBarrageCell *> *)barrages
{
    self.count += barrages.count;
    [self.dataArray addObjectsFromArray:barrages];
}

- (void)start
{
    if (self.status == EStatusOfBarrage_Start) {
        return;
    }
    self.status = EStatusOfBarrage_Start;
    // 创建弹幕
    [self creatBarrage];
}

- (void)stop
{
    if (self.status == EStatusOfBarrage_Stop) {
        return;
    }
    self.status = EStatusOfBarrage_Stop;
    //暂停动画
    if (self.showBarrages.count) {
        [self.showBarrages makeObjectsPerformSelector:@selector(pause)];
    }
    //取消缓存动画
    if (self.dataArray.count > 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    
    //清除缓存
    [self.showBarrages  makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.channelCount       = 0;
    self.count              = 0;
    [self.showBarrages  removeAllObjects];
    [self.dataArray     removeAllObjects];
    [self.channelArray  removeAllObjects];
    
    self.showBarrages       = nil;
    self.dataArray          = nil;
    self.channelArray       = nil;
}

#pragma mark - <Private Method>
- (NSInteger)zb_canBarrageSendInTheChannel:(ZBLiveBarrageCell *)newBarrage
{
    for (int row = 0; row<_channelArray.count; row++) {
        NSObject *object = _channelArray[row];
        if ([object isKindOfClass:[NSNumber class]]) { // 没有最后一条弹幕
            
            return row;
            
        }else if ([object isKindOfClass:[ZBLiveBarrageCell class]]) { // 获取最后一条弹幕
            
            ZBLiveBarrageCell *oldBarrage = (ZBLiveBarrageCell*)object;
            
            if ([self zb_canBarrageSendInTheChannel:oldBarrage newBullet:newBarrage]) {
                
                return row;
            }
        }
    }
    
    return -1;
}

// 判断弹幕是否碰撞方法
- (BOOL)zb_canBarrageSendInTheChannel:(ZBLiveBarrageCell *)oldBarrage newBullet:(ZBLiveBarrageCell *)newBarrage
{
    // 弹幕延时进出时
    if (oldBarrage.status == EStatusOfBarrage_AfterDelay) {
        return NO;
    }
    
    // 获取动画中，控件的frame
    CGRect rect = [oldBarrage.layer.presentationLayer frame];
    if (rect.origin.x>BARRAGE_WIDTH - oldBarrage.frame.size.width) {
        // 当前弹幕还没完全显示在屏幕中，返回NO
        return NO;
    }else if (rect.size.width == 0)
    {
        // 刚刚添加的控件，有可能取到frame的值全为0，也要返回NO
        return NO;
    }
    else if (oldBarrage.barrageShowDuration == newBarrage.barrageShowDuration && oldBarrage.frame.size.width > newBarrage.frame.size.width) {
        // 排除了以上两种情况，比较弹幕的宽度（也就是比较速度）,新弹幕宽度小也就是永远追不上上一条弹幕,返回YES
        return YES;
    }else
    {
        // time为新弹幕从出现到屏幕最左边的时间（此时弹幕整体都在屏幕内，并不是弹幕消失的时间）
        CGFloat time = BARRAGE_WIDTH/(BARRAGE_WIDTH+newBarrage.frame.size.width)*newBarrage.barrageShowDuration;
        // endX为此时老弹幕的frame的x值
        CGFloat endX = rect.origin.x - time/(oldBarrage.barrageShowDuration)*(BARRAGE_WIDTH + oldBarrage.frame.size.width);
        if (endX < -oldBarrage.frame.size.width) {
            // 若此时老弹幕已经完全从屏幕中消失，返回YES
            return YES;
        }
    }
    return NO;
}


// 获取弹幕点击事件（因为视图在动画过程中不能响应手势，所以只能通过计算来响应用户的手势点击事件）
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint clickPoint  = [touch locationInView:self];
    for (ZBLiveBarrageCell *barrageView in [self subviews])
    {
        if ([barrageView.layer.presentationLayer hitTest:clickPoint])
        {
            // This barrageView was hit whilst moving - do something with it here
            if ([self.delegate respondsToSelector:@selector(zb_barrageView:didSelectedCell:)]) {
                [self.delegate zb_barrageView:self didSelectedCell:barrageView];
            }
            break;
        }
    }
}

#pragma mark - Setter/Getter

// 数据源
- (NSMutableArray<ZBLiveBarrageCell *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

// 正在飞翔的弹幕
- (NSMutableArray<ZBLiveBarrageCell *> *)showBarrages {
    if (!_showBarrages) {
        _showBarrages = [[NSMutableArray alloc] init];
    }
    return _showBarrages;
}

// 轨道数组 (可动态改变)
- (void)setChannelCount:(NSInteger)channelCount
{
    
    if (self.channelArray.count < channelCount) { // 新轨道数大于旧轨道数
        
        for (NSInteger row = self.channelArray.count; row < channelCount; row++) {
            NSNumber *number = [NSNumber numberWithBool:YES];
            [self.channelArray setObject:number atIndexedSubscript:row];
        }
        
    }else {
        
        for (NSInteger row = channelCount; row < self.channelArray.count; row++) {
            [self.channelArray removeObjectAtIndex:row];
        }
    }
    
    _channelCount = channelCount;
    
}

// 轨道数组(存放弹幕用于弹幕碰撞检测)
- (NSMutableArray *)channelArray {
    if (!_channelArray) {
        _channelArray = [[NSMutableArray alloc] init];
    }
    return _channelArray;
}

@end
