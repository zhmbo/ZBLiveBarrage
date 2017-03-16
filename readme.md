### ZBLiveBarrage
===

直播应用中一套弹幕实现方案。

###### 弹幕效果:
![image](https://github.com/zhang-bao/ZBLiveBarrage/blob/master/barrageEffect.gif)


###### 弹幕君说:
-  我会飞~~~(gun~，你咋不上天！！)；
- 我的大小你做主；
- 我飞的速度你来定，让我飞多快我飞多快（PS:恩！真听话）；
- 我的衣服你来买(弹幕样式自定义)；
- 我们弹幕家族自带磁场从来不会叠加碰撞的哦(⊙o⊙)；
- 你点我我就告诉你你点的是我而不是我爸（superView）也不会是我的兄弟姐妹O(∩_∩)O~：

![image](http://upload-images.jianshu.io/upload_images/1874013-2577c13823d6b53c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
)
- 直播弹幕 ** ZBLiveBarrage ** 最懂你！！

### 目录结构：
![image](http://upload-images.jianshu.io/upload_images/1874013-afa91c4f92aae840.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 技术剖析：
> 这里只分析弹幕实现具体逻辑，详细代码请下载项目根据以下分析理解。

- 插入弹幕到数组
通过函数`- (void)insertBarrages:(NSArray <ZBLiveBarrageCell *> *)barrages`
向实例 `ZBLiveBarrage`  的 `dadaArray` 属性添加 `ZBLiveBarrageCell` 弹幕数组。

- 创建弹幕

```
- (void)creatBarrage
{
    if (self.dataArray.firstObject) {
        
        // 取出弹幕数组里第一条未展示的弹幕
        ZBLiveBarrageCell *barrageView = self.dataArray.firstObject;
        
        // 通过 函数 zb_canBarrageSendInTheChannel 判断这条弹幕是否有可用跑道让其展示
        NSInteger row = [self zb_canBarrageSendInTheChannel:barrageView];

        // 若果有可用跑到
        if (row >= 0) { 
              barrageView  开始执行 animateWithDuration 在 当前跑道 row 展示弹幕
         }

     }

    //  再次执行 creatBarrage 方法
    [self performSelector:@selector(creatBarrage) withObject:nil afterDelay:0.1f];
}
``` 
- 判断最新弹幕是否有可用跑道让其展示
 `channelArray` 与 `channelCount` 是对应的，`channelCount` 是外界用来设置弹幕轨道数的属性，`channelArray` 是用来存放每条轨道上最后一条弹幕，如果没有弹幕经过轨道默认赋值 `NSNumber ` 实例。

```
- (NSInteger)zb_canBarrageSendInTheChannel:(ZBLiveBarrageCell *)newBarrage
{
    // 遍历轨道数组
    for (id object  in _channelArray) {

        if ([object isKindOfClass:[NSNumber class]]) {
            
            //  如果最后一条没有最后一条弹幕，返回当前跑到
            return row;
            
        }else if ([object isKindOfClass:[ZBLiveBarrageCell class]]) { 

            // 获取最后一条弹幕
            ZBLiveBarrageCell *oldBarrage = (ZBLiveBarrageCell*)object;
            
            // 通过 zb_canBarrageSendInTheChannel: newBullet: 函数 实现新弹幕与当前跑道上最后一条弹幕的 碰撞检测
            if ([self zb_canBarrageSendInTheChannel:oldBarrage newBullet:newBarrage]) {
                
                return row;
            }
        }
    }
    
    return -1;
}
```
- 碰撞检测
`- (BOOL)zb_canBarrageSendInTheChannel:(ZBLiveBarrageCell *)oldBarrage newBullet:(ZBLiveBarrageCell *)newBarrage`
返回值为 BOOL 是否有可能碰撞，思路：
`我们暂且称当前轨道最后一条弹幕为【老弹幕】，将要展示的弹幕为【新弹幕】`

```
if (【老弹幕】还没完全显示在屏幕中) {

    return NO；

}else if (【老弹幕】的宽度为 0 时) {

    // 刚刚添加的控件，有可能取到frame的值全为0，也要返回NO
    return NO;

} else if  (如果【老弹幕】与【新弹幕】的展示时间相同 && 【老弹幕】的宽度 > 【新弹幕】的宽度)  {

    //  比较弹幕的宽度（也就是比较速度）,如果弹幕在屏幕中停留的时间都一样，【新弹幕】宽度小于【老弹幕】就是永远追不上上一条弹幕,返回YES
    return YES;

} else {

        // time为新弹幕从出现到屏幕最左边的时间（此时弹幕整体都在屏幕内，并不是弹幕消失的时间）
        CGFloat time = 屏幕宽度/(屏幕宽度+【新弹幕】的宽度)*【新弹幕】的展示时间;
        // endX为此时老弹幕的frame的x值
        CGFloat endX = 【老弹幕】的 x - time/(【老弹幕展示时间】)*(屏幕宽度 + 【新弹幕】的宽度);
        if (endX < -【新弹幕】的宽度) {
            // 若此时老弹幕已经完全从屏幕中消失，返回YES
            return YES;
        }
    }
    return NO;
}

```

- 弹幕点击事件
因为视图在动画过程中不能响应手势，所以只能通过计算来响应用户的手势点击事件

```
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint clickPoint  = [touch locationInView:self];
    for (ZBLiveBarrageCell *barrageView in [self subviews])
    {
        if ([barrageView.layer.presentationLayer hitTest:clickPoint])
        { 
          // 来到这里说明此条弹幕被点击
        }
            break;
        }
    }
}
```
- 代理事件

```
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
```

### 小结
===

这一套弹幕实现核心代码在于`弹幕碰撞监测`那部分，是不是很简单那？

如果觉得对您有所帮助，点击 Star 666 !

详细分析[简书地址](http://www.jianshu.com/p/46039a38d170) 


## 安装
===

#### CocoaPods
1. 在 Podfile 中添加 pod 'ZBLiveBarrage'。
2. 执行 pod install 或 pod update。
3. 具体应用请下载项目查看。

#### 手动安装
下载 ZBLiveBarrage 文件夹内的所有内容。
将 ZBLiveBarrage 下四个源文件添加(拖放)到你的工程。
