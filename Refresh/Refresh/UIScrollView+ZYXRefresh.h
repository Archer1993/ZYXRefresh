//
//  UIScrollView+ZYXRefresh.h
//  Refresh
//
//  Created by mac mini on 16/9/27.
//  Copyright © 2016年 Archer_Z. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYXHeaderRefreshView.h"
#import "ZYXFooterRefreshView.h"
#import<objc/runtime.h>

@interface UIScrollView (ZYXRefresh)

-(void)addRefreshWithTarget:(id)target  headerSelect:(SEL)headerSelect  footerSelect:(SEL)footerSelect;

-(void)stopHeaderRefresh;
-(void)stopFooterRefresh;

-(void)startHeaderRefresh;
-(void)startFooterRefresh;

@property (strong,nonatomic)ZYXHeaderRefreshView *header;
@property (strong,nonatomic)ZYXFooterRefreshView *footer;

@end
