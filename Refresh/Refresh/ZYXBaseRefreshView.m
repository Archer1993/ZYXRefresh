//
//  ZYXBaseRefreshView.m
//  Refresh
//
//  Created by mac mini on 16/9/27.
//  Copyright © 2016年 Archer_Z. All rights reserved.
//

#import "ZYXBaseRefreshView.h"

@implementation ZYXBaseRefreshView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //初始化状态均为正常状态
        self.headerRefreshState =STATE_NORMAL;
        self.footerRefreshState =STATE_NORMAL;
    }
    return self;
}

//将要显示在父视图时调用，此时添加KVO监听表格偏移量
-(void)willMoveToSuperview:(UIView *)newSuperview
{
    //记录父视图
    _superScrollView = (UITableView*)newSuperview;
    //添加KVO监听父视图的偏移量
    [newSuperview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //获取父视图偏移量
    CGFloat offY =_superScrollView.contentOffset.y;
    //定义新的头，尾刷新状态（待会要判断状态是否发生改变，没改变就不用更新了，为什么要这样呢，后面会知道）
    REFRESHSTATE   newHeaderState, newFooterState;
    
    self.superScrollViewContentOffY = offY;  //此处用set方法设置contentOffY,方便子类调用set方法，做其他处理
    
    //-----------------------更新头部刷新状态-------------------------
    if (self.headerRefreshState ==STATE_STARTREFRESH)
    {
        //这里注意，当头部处于刷新状态时，就不能根据父视图的偏移量来判断状态了，因为在未停止前，刷新状态一直要保持，直到用户调用停止刷新方法
        newHeaderState =STATE_STARTREFRESH;
    }
    else
    {
        if (offY <= -K_HEADER_MAXOFFY)//到达临界值时
        {
            if (_superScrollView.isDragging)
            {
                //手指未松开，保持预备刷新状态
                newHeaderState =STATE_DIDPREPARETOREFRESH;
            }
            else
            {
                //手指松开，立即进入开始刷新状态
                newHeaderState =STATE_STARTREFRESH;
            }
        }
        else
        {
            //小余临界值，正常状态
            newHeaderState =STATE_NORMAL;
        }
    }
    
    //如果头部刷新状态发生了改变就更新
    if (_headerRefreshState != newHeaderState)
    {
        self.headerRefreshState = newHeaderState;
    }
    
    //*************************
    //这里是为了解决尾部刷新的一个BUG,可以先不管
    if (_superScrollViewContentSize.height ==0)
    {
        //当未获取到父视图的大小时，不更新底部状态，直接返回
        return;
    }
    //*************************
    
    
    //-------------------------更新尾部刷新状态---------------------------
    if (self.footerRefreshState == STATE_STARTREFRESH)
    {
        //同头部刷新一样
        //当底部处于刷新状态时，未结束前一直是刷新状态
        newFooterState =STATE_STARTREFRESH;
    }
    else
    {
        //这里要用到父视图（表格）的高度，（待会我们会在CHEFooterRefreshView里为其设置）
        if (offY +_superScrollView.bounds.size.height >= _superScrollViewContentSize.height +K_FOOTER_MAXOFFY)   //到达临界值时
        {
            if (_superScrollView.isDragging)
            {
                //手指未松开，保持准备刷新状态
                newFooterState =STATE_DIDPREPARETOREFRESH;
            }
            else
            {
                //手指松开，立即进入开始刷新状态
                newFooterState =STATE_STARTREFRESH;
            }
        }
        else
        {
            //小余临界值，正常状态
            newFooterState =STATE_NORMAL;
        }
    }
    
    
    //同头部刷新一样，更新底部状态
    if (_footerRefreshState != newFooterState)
    {
        self.footerRefreshState = newFooterState;
    }
}

//开始刷新，由子类去实现
-(void)startRefresh{

}

//结束刷新，由子类去实现
-(void)stopRefresh{
    
}

@end
