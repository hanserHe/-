//
//  ViewController.m
//  ThreadSafety
//
//  Created by Hanser on 10/10/2017.
//  Copyright © 2017 Mr.H. All rights reserved.
//

#import "ViewController.h"
#import "MJRefresh.h"
#import "UIView+Additions.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define scale pow(3, 0.3)

static const CGFloat MJDuration = 2.0;



@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIScrollView *scrollView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.autoresizesSubviews = NO;
    self.navigationItem.title = @"Hanser";
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.tableView];
    [self.scrollView addSubview:self.headerView];

    // 下拉刷新
    _tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 结束刷新
            [_tableView.mj_header endRefreshing];
        });
    }];

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [self.tableView.mj_header beginRefreshing];
}



#pragma mark - Init
- (UITableView *)tableView {
    if (_tableView) {
        return _tableView;
    }
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 300, ScreenWidth, _scrollView.contentSize.height-300) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
//    _tableView.userInteractionEnabled = NO;
//    _tableView.tableHeaderView = self.headerView;
    return _tableView;
}

- (UIView *)headerView {
    if (_headerView) {
        return _headerView;
    }
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 300)];
    _headerView.backgroundColor = [UIColor greenColor];
    return _headerView;
}

- (UIScrollView *)scrollView {
    if (_scrollView) {
        return _scrollView;
    }
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight)];
    _scrollView.scrollsToTop = NO;
//    _scrollView.scrollEnabled = NO;
    _scrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight*2);
    _scrollView.delegate = self;
    return _scrollView;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor redColor];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.mj_offsetY;
    if (scrollView == self.scrollView) {
        NSLog(@"tableView    %f",scrollView.mj_offsetY);
        if (offsetY < 0) {
            scrollView.mj_offsetY = 0;
            if (offsetY < -30) {
                [self.tableView.mj_header beginRefreshing];
            }
        
        }
    }
    
    
    if (scrollView == self.tableView) {
        if (offsetY > 0) {
            
        }
    }else {
        
    }
    
//    [self setScrollViewOffersetY:scrollView.mj_offsetY];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self setScrollViewOffersetY:scrollView.mj_offsetY];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self setScrollViewOffersetY:scrollView.mj_offsetY];
}

#pragma mark - other
- (void)setScrollViewOffersetY:(CGFloat)offsetY {
    if (offsetY < 0) {
        offsetY = 0;
    }
    CGFloat topMargin = 0 - offsetY;
//    [self.headerView setTop:topMargin];
    self.scrollView.mj_offsetY = offsetY;
}

@end
