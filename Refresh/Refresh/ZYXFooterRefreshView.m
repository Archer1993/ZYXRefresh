//
//  ZYXFooterRefreshView.m
//  Refresh
//
//  Created by mac mini on 16/9/27.
//  Copyright © 2016年 Archer_Z. All rights reserved.
//

#import "ZYXFooterRefreshView.h"
#import <objc/message.h>



@implementation ZYXFooterRefreshView
{
    UILabel                   *_label;        //提示标题
    UIImageView               *_imageView;    //上拉箭头图标
    UIActivityIndicatorView   *_activityView; //刷新活动指示器
}
//将要显示在父视图上时调用
-(void)willMoveToSuperview:(UIView *)newSuperview
{
    //此处切记得调用父类的方法，因为在父类的方法中添加了另一个KVO监听
    [super willMoveToSuperview:newSuperview];
    
    //添加尾部加载时要监听父视图的大小（高度）变化
    //监听父视图大小变化
    [newSuperview addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //此处要记得调用父类的KVO代理方法，不然之前写的代码就没用了
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if (self.superScrollViewContentSize.height != self.superScrollView.contentSize.height) {
        self.superScrollViewContentSize = self.superScrollView.contentSize;
        //更新自己的位置，让自己始终显示在表格的最下面
        [self updateFrame];

    }
}

-(void)updateFrame
{
    self.frame =CGRectMake(0,self.superScrollViewContentSize.height,self.bounds.size.width,K_FOOTER_REFRESHVIEW_WH);
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _label = [[UILabel alloc]initWithFrame:CGRectMake(0,K_BORDER,self.bounds.size.width,K_TITLE_WH)];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment =NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:16];
        _label.textColor = [UIColor blackColor];
        _label.text =K_FOOT_NORMAL_TITLE;
        [self addSubview:_label];
        
         NSDictionary *_attrbute = @{NSFontAttributeName:[UIFont systemFontOfSize:16]};
        CGSize  size = [K_FOOT_NORMAL_TITLE boundingRectWithSize:CGSizeMake(1000, K_TITLE_WH) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:_attrbute context:nil].size;
        
        CGFloat oriX =self.bounds.size.width /2 - size.width /2 -K_TITLE_WH *1.2;
        
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(oriX,K_BORDER -2.5,K_TITLE_WH *1.2,K_TITLE_WH *1.2)];

        
        _imageView.image = [UIImage imageNamed:@"arrow.png"];
        _imageView.contentMode =UIViewContentModeScaleAspectFit;
        _imageView.transform =CGAffineTransformMakeRotation(M_PI);
        [self addSubview:_imageView];
        
      
    }
    return self;
}


-(void)setFooterRefreshState:(REFRESHSTATE)footerRefreshState
{
    //记得要先调用父类的方法，保存刷新状态
    [super setFooterRefreshState:footerRefreshState];
    
    if (footerRefreshState ==STATE_NORMAL)
    {
        _label.text =K_FOOT_NORMAL_TITLE;
        _imageView.hidden =NO;
        if (_activityView != nil) {
            [_activityView stopAnimating];
        }
        

        [UIView animateWithDuration:0.2 animations:^{
            
            _imageView.transform =CGAffineTransformMakeRotation(M_PI);
            
            //如果不在返回这里将scrollview的contentinset调回来的话，那么后面上拉刷新view会一直显示出来。
            //此时要记录下拉刷新时顶部是否有增加的高度
            UIEdgeInsets  insert =self.superScrollView.contentInset;
            [self.superScrollView setContentInset:UIEdgeInsetsMake(insert.top,0,0,0)];
            
        }];
        
    }
    else if (footerRefreshState ==STATE_DIDPREPARETOREFRESH)
    {
        _label.text =K_FOOT_PREPARE_TITLE;
        _imageView.hidden =NO;
        if (_activityView != nil) {
            [_activityView stopAnimating];
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            
            _imageView.transform =CGAffineTransformIdentity;
            
        }];
        
    }
    else if (footerRefreshState ==STATE_STARTREFRESH)
    {
        _label.text =K_FOOT_START_TITLE;
        _imageView.hidden =YES;
        
        //传递开始加载消息
        objc_msgSend(self.selecterTarget,self.refreshSelecter);
        
        //此时要记录下拉刷新时顶部是否有增加的高度
        UIEdgeInsets  insert =self.superScrollView.contentInset;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            [self.superScrollView setContentInset:UIEdgeInsetsMake(insert.top,0,K_FOOTER_MAXOFFY,0)];
            
        }];
        
        
        if (!_activityView)
        {
            //添加活动指示器
            _activityView = [[UIActivityIndicatorView alloc]initWithFrame:_imageView.frame];
            _activityView.activityIndicatorViewStyle =UIActivityIndicatorViewStyleGray;
            _activityView.hidesWhenStopped =YES;
            [self addSubview:_activityView];
            
        }
        
        [_activityView startAnimating];
    }
}

//开始刷新
-(void)startRefresh
{
    [self.superScrollView setContentOffset:CGPointMake(0,self.superScrollViewContentSize.height + K_HEADER_MAXOFFY) animated:YES];
    self.footerRefreshState =STATE_STARTREFRESH;
}

//结束刷新
-(void)stopRefresh
{
    //如果把封住的代码打开，那么上拉加载之后，tableview会下弹回原位置，看具体需求进行调整。
    //如果想要随意调整偏移量，可以尝试将UIEdgeInsets换成cgpoint，然后调整tableview的ContentOffset
    
    //此时要记录下拉刷新时顶部是否有增加的高度
//    UIEdgeInsets  insert =self.superScrollView.contentInset;
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        
//        [self.superScrollView setContentInset:UIEdgeInsetsMake(insert.top ,0,0,0)];
//    }];
    
    self.footerRefreshState = STATE_NORMAL;
}



@end
