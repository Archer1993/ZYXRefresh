//
//  ViewController.m
//  Refresh
//
//  Created by mac mini on 16/9/27.
//  Copyright © 2016年 Archer_Z. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+ZYXRefresh.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

//@property (strong, nonatomic) UITableView *tableview;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic) NSMutableArray *arr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //为了防止系统自动将tableview进行偏移64
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    _arr = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10", nil];
    

//    _tableview  = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64) style:UITableViewStylePlain];
    _tableview.backgroundColor = [UIColor whiteColor];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    [_tableview addRefreshWithTarget:self headerSelect:@selector(headerSelector) footerSelect:@selector(footerSelector)];

    [self.view addSubview:_tableview];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];
}

- (void)headerSelector{
    NSLog(@"竟然可以哟");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_tableview stopHeaderRefresh];
    });
}

- (void)footerSelector{
    NSLog(@"真的可以哦");
    

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
        for (int i = 0; i < 10; i++) {
            NSString *str = [_arr lastObject];
            NSInteger num = [str integerValue] + 1;
            NSString *s = [NSString stringWithFormat:@"%ld",(long)num];
            
            [_arr addObject:s];
        }
        //最好先刷新在停止footerRefreshView，不然刷新的时候造成的滚动也会调用刷新的方法
        [_tableview reloadData];
        [_tableview stopFooterRefresh];
    });

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
 
    return _arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"test";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = _arr[indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
