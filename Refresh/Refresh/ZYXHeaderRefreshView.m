//
//  ZYXHeaderRefreshView.m
//  Refresh
//
//  Created by mac mini on 16/9/27.
//  Copyright © 2016年 Archer_Z. All rights reserved.
//

#import "ZYXHeaderRefreshView.h"
#import <objc/message.h>


@implementation ZYXHeaderRefreshView
{
    UILabel                   *_label;       //提示标题
    UILabel                   *_timeLabel;   //刷新时间
    UIImageView               *_imageView;   //下拉箭头
    UIActivityIndicatorView   *_activityView;//刷新时的活动指示器
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _label = [[UILabel alloc]initWithFrame:CGRectMake(0,self.bounds.size.height - (K_TITLE_WH + K_BORDER + K_TITLE_WH),self.bounds.size.width,K_TITLE_WH)];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment =NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:16];
        _label.textColor = [UIColor blackColor];
        _label.text =K_HEAD_NORMAL_TITLE;
        [self addSubview:_label];
        
        
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(_label.frame),self.bounds.size.width,K_TITLE_WH)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textAlignment =NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textColor = [UIColor grayColor];
        NSString  *time = [[NSUserDefaults standardUserDefaults]objectForKey:@"LastRefreshTime"];
        _timeLabel.text = time.length >0 ? [NSString stringWithFormat:@"最后刷新 : %@",time] :@"最近未刷新";
        [self addSubview:_timeLabel];
        
        NSDictionary *_attrbute = @{NSFontAttributeName:[UIFont systemFontOfSize:16]};
        CGSize  size = [K_HEAD_NORMAL_TITLE boundingRectWithSize:CGSizeMake(1000, K_TITLE_WH) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:_attrbute context:nil].size;
        
        CGFloat oriX =self.bounds.size.width /2 - size.width /2 -K_TITLE_WH *1.2;
        
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(oriX,_label.frame.origin.y -2.5, K_TITLE_WH *1.2,K_TITLE_WH *1.2)];
        _imageView.image = [UIImage imageNamed:@"arrow.png"];
        _imageView.contentMode =UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    
    }
    return self;
}


//头部刷新状态改变时掉用
-(void)setHeaderRefreshState:(REFRESHSTATE)headerRefreshState
{
    //记得要先调用父类的方法，保存刷新状态
    [super setHeaderRefreshState:headerRefreshState];
    
    if (headerRefreshState ==STATE_NORMAL)
    {
        //正常状态
        _label.text =K_HEAD_NORMAL_TITLE;
        
        [_activityView stopAnimating];
        _imageView.hidden =NO;
        
        //旋转箭头图标为正常
        [UIView animateWithDuration:0.2 animations:^{
            _imageView.transform =CGAffineTransformIdentity;
        }];
    }
    else if (headerRefreshState ==STATE_DIDPREPARETOREFRESH)
    {
        //准备刷新状态
        _label.text =K_HEAD_PREPARE_TITLE;
        
        [_activityView stopAnimating];
        _imageView.hidden =NO;
        
        //旋转箭头图标朝上
        [UIView animateWithDuration:0.2 animations:^{
            _imageView.transform =CGAffineTransformMakeRotation(M_PI);
        }];
        
    }
    else if (headerRefreshState ==STATE_STARTREFRESH)
    {
        //开始刷新状态
        _label.text =K_HEAD_START_TITLE;
        _imageView.hidden =YES;
        
        //向之前绑定的对象传递开始刷新消息
        objc_msgSend(self.selecterTarget,self.refreshSelecter);
        
        //保存刷新的时间
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
        //用[NSDate date]可以获取系统当前时间
        NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
        _timeLabel.text = [NSString stringWithFormat:@"最后刷新 : %@",currentDateStr];
        
        [[NSUserDefaults standardUserDefaults]setObject:currentDateStr forKey:@"LastRefreshTime"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        //当头部开始刷新时，为头部增加一部分高度，不过此时要先获取底部是否有增加的高度（因为此时尾部可能也在刷新）
        UIEdgeInsets  insert =self.superScrollView.contentInset;
        
        [UIView animateWithDuration:0.2 animations:^{
            
            [self.superScrollView setContentInset:UIEdgeInsetsMake(K_HEADER_MAXOFFY,0, insert.bottom,0)];
            
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
    [self.superScrollView setContentOffset:CGPointMake(0, -K_HEADER_MAXOFFY)animated:YES];
    self.headerRefreshState =STATE_STARTREFRESH;
}

//结束刷新
-(void)stopRefresh
{
    //如果想要随意调整偏移量，可以尝试将UIEdgeInsets换成cgpoint，然后调整tableview的ContentOffset
    
    //此时要记录上拉加载时底部是否有增加的高度
    UIEdgeInsets  insert =self.superScrollView.contentInset;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [self.superScrollView setContentInset:UIEdgeInsetsMake(0,0, insert.bottom,0)];
    }];
    
    self.headerRefreshState =STATE_NORMAL;
}

@end
