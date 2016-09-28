//
//  UIScrollView+ZYXRefresh.m
//  Refresh
//
//  Created by mac mini on 16/9/27.
//  Copyright © 2016年 Archer_Z. All rights reserved.
//

#import "UIScrollView+ZYXRefresh.h"


@implementation UIScrollView (ZYXRefresh)

-(void)addRefreshWithTarget:(id)target  headerSelect:(SEL)headerSelect  footerSelect:(SEL)footerSelect
{
    if (headerSelect)
    {
        //添加头部刷新
        ZYXHeaderRefreshView *header = [[ZYXHeaderRefreshView alloc]initWithFrame:CGRectMake(0, -K_HEADER_REFRESHVIEW_WH,self.bounds.size.width,K_HEADER_REFRESHVIEW_WH)];
        header.refreshSelecter = headerSelect;
        header.selecterTarget = target;
        header.superScrollView =self;
        [self addSubview:header];
    
        self.header = header;
    }
    
    if (footerSelect)
    {
        //添加尾部刷新
        ZYXFooterRefreshView *footer = [[ZYXFooterRefreshView alloc]initWithFrame:CGRectMake(0,self.contentSize.height,self.bounds.size.width,K_FOOTER_REFRESHVIEW_WH)];
        footer.refreshSelecter = footerSelect;
        footer.selecterTarget = target;
        footer.superScrollView =self;
//        footer.scale =1.0;
        [self addSubview:footer];
        
        self.footer = footer;
    }
}

-(void)stopHeaderRefresh
{
    [self.header stopRefresh];
}

-(void)stopFooterRefresh
{
    [self.footer stopRefresh];
}

-(void)startHeaderRefresh
{
    [self.header startRefresh];
}

-(void)startFooterRefresh
{
    [self.footer startRefresh];
}



-(void)setHeader:(ZYXHeaderRefreshView *)header{
    //通过键值"header"将自己的header对象绑定起来
    objc_setAssociatedObject (self,"header", header,OBJC_ASSOCIATION_ASSIGN);
}

-(void)setFooter:(ZYXFooterRefreshView *)footer
{
    objc_setAssociatedObject (self,"footer", footer,OBJC_ASSOCIATION_ASSIGN);
}

-(ZYXHeaderRefreshView *)header
{
    //通过键值"header"读取之前绑定的对象
    return objc_getAssociatedObject(self,"header");
}

-(ZYXFooterRefreshView *)footer
{
    return objc_getAssociatedObject(self,"footer");
}

@end
