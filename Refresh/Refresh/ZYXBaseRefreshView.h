//
//  ZYXBaseRefreshView.h
//  Refresh
//
//  Created by mac mini on 16/9/27.
//  Copyright © 2016年 Archer_Z. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <objc/objc.h>
#include <objc/runtime.h>

#define K_TITLE_WH  30.0  //label的高度
#define K_BORDER   5.0   //label的间距

#define K_HEADER_REFRESHVIEW_WH   150.0                           //头部刷新控件高度
#define K_HEADER_MAXOFFY          K_HEADER_REFRESHVIEW_WH / 2.0    //刷新临界值
#define K_FOOTER_REFRESHVIEW_WH   150.0
#define K_FOOTER_MAXOFFY          K_FOOTER_REFRESHVIEW_WH / 2.0
#define K_HEAD_NORMAL_TITLE            @"下拉即可刷新"
#define K_HEAD_PREPARE_TITLE           @"松开立即刷新"
#define K_HEAD_START_TITLE             @"正在刷新数据"
#define K_FOOT_NORMAL_TITLE            @"上拉即可加载更多"
#define K_FOOT_PREPARE_TITLE           @"松开立即加载更多"
#define K_FOOT_START_TITLE             @"正在加载更多数据"

//刷新状态枚举
typedef enum {
    STATE_NORMAL =1,          //正常状态
    STATE_DIDPREPARETOREFRESH, //预备刷新状态（松开刷新）
    STATE_STARTREFRESH,        //开始刷新状态
} REFRESHSTATE;



@interface ZYXBaseRefreshView : UIView

@property (nonatomic,strong)UIScrollView    *superScrollView;   //父视图（表格scrollView）
@property (nonatomic,weak)  id              selecterTarget;     //刷新事件的绑定对象
@property (nonatomic,assign)SEL             refreshSelecter;    //刷新事件方法选择器
@property (nonatomic,assign)CGFloat         superScrollViewContentOffY;        //父视图的偏移量
@property (nonatomic,assign)CGSize          superScrollViewContentSize;        //父视图的大小
@property (nonatomic,assign)REFRESHSTATE    headerRefreshState; //记录顶部刷新状态
@property (nonatomic,assign)REFRESHSTATE    footerRefreshState; //记录底部刷新状态

-(void)startRefresh;  //开始刷新，由子类去实现
-(void)stopRefresh;   //结束刷新，由子类去实现

@end
