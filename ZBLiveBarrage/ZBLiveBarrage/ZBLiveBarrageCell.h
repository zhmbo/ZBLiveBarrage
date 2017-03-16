//
//  ZBLiveBarrageDescriptor.h
//  LiveBarrage
//
//  Created by 张宝 on 16/12/20.
//  Copyright © 2016年 张宝. All rights reserved.
//  弹幕们的基类，继承此弹幕就行了

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    EStatusOfBarrage_Start,
    EStatusOfBarrage_Stop,
    EStatusOfBarrage_AfterDelay
} EStatusOfBarrage;

@interface ZBLiveBarrageCell : UIView

/** 弹幕︿(￣︶￣)︿飞行速度体积 */
@property (nonatomic, assign) CGSize            barrageSize;

/** 弹幕︿(￣︶￣)︿飞行速度大小 (其实是个伪速度 此值伪弹幕完成动画所需时间) 默认为3s */
@property (nonatomic, assign) CGFloat           barrageShowDuration;

/** 弹幕横向展示之前延迟时间 默认为0s */
@property (nonatomic, assign) CGFloat           barrageDelay;

/** 弹幕ヾ(o◕∀◕)ﾉヾ的新衣服 */
@property (nonatomic, strong) id                model;
/**
 *  我的跑到轨道数 默认3条
 */
@property (nonatomic, assign) NSInteger         channelCount;
/**
 *  距离产生美
 */
@property (nonatomic, assign) CGFloat           margin;
/**
 *  延时谢幕
 */
@property (nonatomic, assign) CGFloat           afterDelayExit;

/**
 *  当前弹幕状态
 */
@property (nonatomic, assign) EStatusOfBarrage status;
/**
 *  开始嘚瑟
 */
- (void)startAnimations:(void(^)(void))animations completion:(void(^)(BOOL))completion;
/**
 *  休息一会
 */
- (void)pause;
/**
 *  继续︿(￣︶￣)︿飞
 */
- (void)resume;
@end
