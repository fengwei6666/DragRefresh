//
//  YKDragRefreshTableView.m
//  YKElectronic
//
//  Created by wei feng on 15/3/14.
//  Copyright (c) 2015年 wei feng. All rights reserved.
//

#import "YKDragRefreshTableView.h"
#import "UDNomalRefreshHeaderView.h"
#import "UDNomalRefreshFooterView.h"
#import "UDZ800RefreshHeaderView.h"

@interface YKDragRefreshTableView()
{
    UDRefreshBaseView *_headerView;
    UDRefreshBaseView *_footerView;
}

@end

@implementation YKDragRefreshTableView

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"contentSize" context:nil];
}

- (void)awakeFromNib
{
    [self addObserver:self forKeyPath:@"contentSize"
              options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
              context:nil];
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style])
    {
        [self addObserver:self forKeyPath:@"contentSize"
                  options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                  context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *newValue = [[change objectForKey:@"new"] description];
        NSString *oldValue = [[change objectForKey:@"old"] description];
        if ([newValue hasPrefix:@"NSSize"] && [oldValue hasPrefix:@"NSSize"])
        {
            CGSize newSize = CGSizeFromString(newValue);
            CGSize oldSize = CGSizeFromString(oldValue);
            if (!CGSizeEqualToSize(newSize, oldSize) && self.footerView)
            {
                [self.footerView scrollViewDidSizeChanged:newSize]; //通知底部视图调整位置
            }
        }
    });
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self initRefreshHeaderFooterView];
}

- (void)initRefreshHeaderFooterView
{
    if (!_headerView && self.refreshDataSource &&
        [self.refreshDataSource respondsToSelector:@selector(refreshHeaderViewStyleInTableView:)])
    {
        UDRefreshViewStyle headerStyle = [self.refreshDataSource refreshHeaderViewStyleInTableView:self];
        
        if (headerStyle == UDRefreshViewStyleNormal)
        {
            _headerView = [[UDNomalRefreshHeaderView alloc] initWithFrame:CGRectZero];
        }
        else if (headerStyle == UDRefreshViewStyleZ800)
        {
            _headerView = [[UDZ800RefreshHeaderView alloc] initWithFrame:CGRectZero];
        }
        
        __weak YKDragRefreshTableView *sself = self;
        self.headerView.didPullingUp = ^(UDRefreshBaseView *headerView){
            if (sself.refreshDelegate && [sself.refreshDelegate respondsToSelector:@selector(tableView:refreshHeaderViewDidpullup:)])
            {
                [sself.refreshDelegate tableView:sself refreshHeaderViewDidpullup:sself.headerView];
            }
        };
        
        if (!self.headerView.superview)
        {
            [self addSubview:self.headerView];
        }
    }
    
    if (!_footerView && [self.refreshDataSource respondsToSelector:@selector(refreshFooterViewStyleInTableView:)])
    {
        UDRefreshViewStyle footerStyle = [self.refreshDataSource refreshFooterViewStyleInTableView:self];
        
        if (footerStyle == UDRefreshViewStyleNormal)
        {
            _footerView = [[UDNomalRefreshFooterView alloc] initWithFrame:CGRectZero];
        }
        
        __weak YKDragRefreshTableView *sself = self;
        self.footerView.didPullingDown = ^(UDRefreshBaseView *footerView){
            if (sself.refreshDelegate && [sself.refreshDelegate respondsToSelector:@selector(tableView:refreshFooterViewDidpullDown:)])
            {
                [sself.refreshDelegate tableView:sself refreshFooterViewDidpullDown:sself.footerView];
            }
        };
        
        if (!self.footerView.superview)
        {
            [self addSubview:self.footerView];
        }
    }
}

#pragma mark - TableView Scroll

- (void)tableViewDidScroll
{
    if (self.headerView && (self.footerView.status != UDRefreshLoading)) //上拉视图
        [self.headerView scrollViewDidScroll:self]; //正在滑动
    
    if (self.footerView && (self.headerView.status != UDRefreshLoading)) //下拉视图
        [self.footerView scrollViewDidScroll:self];
}

- (void)tableViewDidEndDraggingWillDecelerate:(BOOL)decelerate
{
    if (self.headerView && (self.footerView.status != UDRefreshLoading)) //上拉视图
        [self.headerView scrollViewDidEndDragging:self willDecelerate:decelerate]; //滑动完成
    
    if (self.footerView && (self.headerView.status != UDRefreshLoading)) //下拉视图
        [self.footerView scrollViewDidEndDragging:self willDecelerate:decelerate];
}

- (void)tableViewDidEndDecelerating
{
    if (self.headerView && (self.footerView.status != UDRefreshLoading)) //上拉视图
        [self.headerView scrollViewDidEndDecelerating:self]; //滑动完成
    
    if (self.footerView && (self.headerView.status != UDRefreshLoading)) //下拉视图
        [self.footerView scrollViewDidEndDecelerating:self];
}

- (void)resetRefreshViewStatus
{
    [_headerView setStatus:UDRefreshNormal];
    [_footerView setStatus:UDRefreshNormal];
}

@end
