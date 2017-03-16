//
//  ZBLiveBarrage.h
//  LiveBarrage
//
//  Created by 张宝 on 16/12/15.
//  Copyright © 2016年 张宝. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBLiveBarrageCell.h"

@protocol ZBLiveBarrageDelegate;

#pragma mark - <弹幕>
@interface ZBLiveBarrage : UIView
/**
 *  事件交互协议
 */
@property (weak, nonatomic) id<ZBLiveBarrageDelegate> delegate;

/**
 *  发送弹幕（必须先调用 startAnimation 函数 否则无效，会在 startAnimation 后启动）
 */
- (void)insertBarrages:(NSArray <ZBLiveBarrageCell *> *)barrages;
/**
 *  启动弹幕
 */
- (void)start;
/**
 *  停止动画,所有的缓存数据都会被清空
 */
- (void)stop;

@end

#pragma mark - <弹幕事件交互协议>
@protocol ZBLiveBarrageDelegate <NSObject>

@optional
/**
 *  弹幕点击事件回调
 */
- (void)zb_barrageView:(ZBLiveBarrage *)barrageView didSelectedCell:(ZBLiveBarrageCell *)cell;
/**
 *  当前插入的弹幕模型数组全部展示完成回调
 */
- (void)zb_barrageViewCompletedCurrentAnimations;
/**
 *  弹幕即将显示时回调
 */
- (void)zb_barrageView:(ZBLiveBarrage *)barrageView willDisplayCell:(ZBLiveBarrageCell *)cell;
/**
 *  弹幕显示完成回调
 */
- (void)zb_barrageView:(ZBLiveBarrage *)barrageView didEndDisplayingCell:(ZBLiveBarrageCell *)cell;

@end
