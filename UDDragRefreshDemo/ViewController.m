//
//  ViewController.m
//  UDDragRefreshDemo
//
//  Created by wei feng on 3/2/15.
//  Copyright (c) 2015 wei feng. All rights reserved.
//

#import "ViewController.h"
#import "UDNomalRefreshHeaderView.h"
#import "UDNomalRefreshFooterView.h"
#import "UDZ800RefreshHeaderView.h"
#import "YKDragRefreshTableView.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, YKDragRefreshTableViewRefreshDelegate, YKDragRefreshTableViewRefreshDataSource>
{
    NSInteger _currentPageNumber;
}

@property (weak,   nonatomic) IBOutlet YKDragRefreshTableView *udTableView;

@end

@implementation ViewController

- (void)dealloc
{
//    [self.udTableView removeObserver:self forKeyPath:@"contentSize" context:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _currentPageNumber = 1;
    
    [self.udTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"nomalCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nomalCell"];
    cell.textLabel.text = [NSString stringWithFormat:@"第 %d 行", indexPath.row];
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.udTableView tableViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.udTableView tableViewDidEndDraggingWillDecelerate:decelerate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.udTableView tableViewDidEndDecelerating];
}

- (UDRefreshViewStyle)refreshFooterViewStyleInTableView:(YKDragRefreshTableView *)tableView
{
    return UDRefreshViewStyleNormal;
}

- (UDRefreshViewStyle)refreshHeaderViewStyleInTableView:(YKDragRefreshTableView *)tableView
{
    return UDRefreshViewStyleZ800;
}

- (void)tableView:(YKDragRefreshTableView *)tableView refreshFooterViewDidpullDown:(UDRefreshBaseView *)footerView
{
    NSLog(@"refresh pull down");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [footerView setStatus:UDRefreshLoaded];
    });
}

- (void)tableView:(YKDragRefreshTableView *)tableView refreshHeaderViewDidpullup:(UDRefreshBaseView *)headerView
{
    NSLog(@"refresh pull up");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [headerView setStatus:UDRefreshLoaded];
    });
}

#pragma mark - public

- (void)resetRefreshViewsStatus
{
    
}

- (void)loadDataFromServer:(NSInteger )pageNumber
{
    
}

@end
