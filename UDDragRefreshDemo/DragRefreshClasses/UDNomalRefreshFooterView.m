//
//  UDNomalRefreshFooterView.m
//  UDDragRefreshDemo
//
//  Created by wei feng on 3/2/15.
//  Copyright (c) 2015 wei feng. All rights reserved.
//

#import "UDNomalRefreshFooterView.h"

@interface UDNomalRefreshFooterView()
{
    UILabel *_textLabel;
    UIActivityIndicatorView *_loadingAIView;
}

/**
 *	@brief 	显示视图
 */
- (void)show;

/**
 *	@brief 	隐藏视图
 */
- (void)hide;

@end

@implementation UDNomalRefreshFooterView

#define kUDRefreshViewHeight        60
#define kUDRefreshLeftRightSpacing  10

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        self.frame = CGRectMake(0, - kUDRefreshViewHeight, width, kUDRefreshViewHeight);
    }
    return self;
}

- (void)setPropertyForLabel:(UILabel*)label
{
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont systemFontOfSize:13]];
    [label setTextColor:[UIColor lightGrayColor]];
    [label setShadowColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    [label setShadowOffset:CGSizeMake(0.0f, 1.0f)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /** 加载的文字信息 */
    if (_textLabel == nil)
    {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self setPropertyForLabel:_textLabel];
        [self addSubview:_textLabel];
        
        [_textLabel setText:@"正在加载..."];
        CGSize size = [_textLabel.text sizeWithFont:_textLabel.font];
        CGFloat x = (self.frame.size.width - size.width) / 2;
        CGFloat y = (self.frame.size.height - size.height) / 2;
        CGRect rect = CGRectMake(x, y, size.width, size.height);
        [_textLabel setFrame:rect];
        
        [self setHidden:YES]; // 隐藏刷新视图
    }
    
    /** 加载的进度提示 */
    if (_loadingAIView == nil)
    {
        CGFloat width = 20.0f;
        CGFloat x = _textLabel.frame.origin.x - width - kUDRefreshLeftRightSpacing;
        CGRect frame = CGRectMake(x, (kUDRefreshViewHeight - width) / 2, width, width);
        _loadingAIView = [[UIActivityIndicatorView alloc] initWithFrame:frame];
        [_loadingAIView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [_loadingAIView startAnimating];
        [self addSubview:_loadingAIView];
    }
}

- (void)setStatus:(UDRefreshStatus)status
{
    switch (status)
    {
        case UDRefreshNormal:
        {
            [self show];
            [self setHidden:NO];
            _textLabel.text = @"正在加载...";
            break;
        }
        case UDRefreshLoaded:
        case UDRefreshAllLoaded:
        {
            [UIView animateWithDuration:0.3f animations:^{
                [self hide];
            } completion:^(BOOL finished) {
                [self setHidden:YES];
            }];
            break;
        }
            
        default:
            break;
    }
    
    _status = status;
}

- (void)selfHidden:(BOOL)hidden
{
    if (self.hidden != hidden)
    {
        self.hidden = hidden;
        hidden ? [self hide] : [self show];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.status != UDRefreshAllLoaded) //视图没有显示
    {
        CGFloat maxYOffset = (scrollView.contentSize.height -
                              CGRectGetHeight(scrollView.bounds) -
                              CGRectGetHeight(self.frame));
        [self selfHidden:!((maxYOffset > 0) && (scrollView.contentOffset.y > maxYOffset))];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ((self.status != UDRefreshLoading) &&
        (self.status != UDRefreshAllLoaded)) //没有正在加载或已经全部加载完
    {
        CGFloat maxYOffset = (scrollView.contentSize.height -
                              CGRectGetHeight(scrollView.bounds) -
                              CGRectGetHeight(self.frame));
        if ((maxYOffset > 0) && (scrollView.contentOffset.y > maxYOffset))
        {
            if ([self.superview isKindOfClass:[UITableView class]] ||
                [self.superview isKindOfClass:[UIScrollView class]])
            {
                self.status = UDRefreshLoading;
                if (self.didPullingDown) self.didPullingDown(self); // 回调通知下拉刷新
            }
        }
    }
}

- (void)scrollViewDidSizeChanged:(CGSize)size
{
    CGRect frame = self.frame;
    frame.origin.y = size.height;
    self.frame = frame;
}

#pragma mark - private methods

- (void)setEdgeInsetOnBottomOfScrollView:(CGFloat)bottom
{
    if ([self.superview isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *scrollView = (UIScrollView*)self.superview;
        UIEdgeInsets edgeInsets = scrollView.contentInset;
        edgeInsets.bottom = bottom; //设置边距
        scrollView.contentInset = edgeInsets;
    }
}

- (void)show
{
    [self setEdgeInsetOnBottomOfScrollView:self.frame.size.height];
}

- (void)hide
{
    [self setEdgeInsetOnBottomOfScrollView:0];
}

@end
