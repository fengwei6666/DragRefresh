//
//  UDNomalRefreshHeaderView.m
//  UDDragRefreshDemo
//
//  Created by wei feng on 3/2/15.
//  Copyright (c) 2015 wei feng. All rights reserved.
//

#import "UDNomalRefreshHeaderView.h"

@interface UDNomalRefreshHeaderView()
{
    UILabel *_textLabel;
    UILabel *_dateLabel;
    UIActivityIndicatorView *_loadingAIView;
    UIImageView *_loadingImageView;
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

@implementation UDNomalRefreshHeaderView

#define kUDRefreshLabelHeight       15
#define kUDRefreshImageViewHeight   27

#define kUDRefreshLeftRightSpacing  10
#define kUDRefreshTopBottomSpacing  5

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = kUDRefreshImageViewHeight + kUDRefreshLabelHeight * 2 +
        kUDRefreshTopBottomSpacing * 3; // 视图的高度
        self.frame = CGRectMake(0, - height, width, height);
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
    
    /* 加载的提示图片 */
    if (_loadingImageView == nil)
    {
        CGFloat width = kUDRefreshImageViewHeight;
        CGRect frame = CGRectMake((self.frame.size.width - width) / 2, 0, width, width);
        _loadingImageView = [[UIImageView alloc] initWithFrame:frame];
        [_loadingImageView setImage:[UIImage imageNamed:@"arrow_new.png"]];
        [self addSubview:_loadingImageView];
    }
    
    /* 加载的进度提示 */
    if (_loadingAIView == nil)
    {
        CGFloat width = 20.0f;
        CGFloat y = _loadingImageView.frame.origin.y + (_loadingImageView.frame.size.height - width) / 2;
        CGRect frame = CGRectMake((self.frame.size.width - width) / 2, y, width, width);
        _loadingAIView = [[UIActivityIndicatorView alloc] initWithFrame:frame];
        [_loadingAIView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_loadingAIView];
    }
    
    /* 加载的文字信息 */
    if (_textLabel == nil)
    {
        CGFloat width = self.frame.size.width - kUDRefreshLeftRightSpacing * 2;
        CGFloat y = CGRectGetMaxY(_loadingImageView.frame) + kUDRefreshTopBottomSpacing;
        CGRect rect = CGRectMake(kUDRefreshLeftRightSpacing, y, width, kUDRefreshLabelHeight);
        _textLabel = [[UILabel alloc] initWithFrame:rect];
        [_textLabel setText:@"下拉刷新"];
        [self setPropertyForLabel:_textLabel];
        [self addSubview:_textLabel];
    }
    
    /* 最后加载的时间信息 */
    if (_dateLabel == nil)
    {
        CGRect rect = _textLabel.frame;
        rect.origin.y = CGRectGetMaxY(rect) + kUDRefreshTopBottomSpacing;
        _dateLabel = [[UILabel alloc] initWithFrame:rect];
        [self setPropertyForLabel:_dateLabel];
        NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:self.identifiler];
        [_dateLabel setText:[self formatDateTime:date]];
        [self addSubview:_dateLabel];
    }
}

- (NSString *)formatDateTime:(NSDate*)date
{
    NSString *result = @"从未";
    if (date)
    {
        NSUInteger interval = [[NSDate date] timeIntervalSinceDate:date];
        if (interval < 60 * 60)
            result = [NSString stringWithFormat:@"最近更新%d分钟前", interval / 60];
        else if (interval < 12 * 60 * 60)
            result = [NSString stringWithFormat:@"最近更新%d小时前", interval / (60 * 60)];
        else
        {
            NSString *format = (interval < 365 * 24 * 60 * 60) ? @"最近更新M月d日" : @"最近更新yyyy年M月d日";
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:format];
            result = [formatter stringFromDate:date];
        }
    }
    
    return result;
}

- (void)setStatus:(UDRefreshStatus)status
{
    switch (status)
    {
        case UDRefreshNormal:
        {
            _textLabel.text = @"下拉刷新";
            NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:self.identifiler];
            _dateLabel.text = [self formatDateTime:date];
            [_loadingAIView setHidden:YES];
            [_loadingAIView stopAnimating];
            [_loadingImageView setHidden:NO];
            [UIView animateWithDuration:0.2f animations:^{
                _loadingImageView.transform = CGAffineTransformIdentity;
            }];
            break;
        }
        case UDRefreshPulling:
        {
            _textLabel.text = @"释放立即刷新";
            [_loadingAIView setHidden:YES];
            [_loadingAIView stopAnimating];
            [_loadingImageView setHidden:NO];
            [UIView animateWithDuration:0.2f animations:^{
                _loadingImageView.transform = CGAffineTransformMakeRotation(M_PI);
            }];
            break;
        }
        case UDRefreshLoading:
        {
            _textLabel.text = @"正在加载...";
            [_loadingAIView setHidden:NO];
            [_loadingAIView startAnimating];
            [_loadingImageView setHidden:YES];
            break;
        }
        case UDRefreshLoaded:
        case UDRefreshAllLoaded:
        {
            [UIView animateWithDuration:0.3f animations:^{
                [self hide]; //加载完成，隐藏
            } completion:^(BOOL finished) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:self.identifiler];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self setStatus:UDRefreshNormal];
            }];
            break;
        }
            
        default:
            break;
    }
    
    _status = status;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.status != UDRefreshLoading) //没有在加载
    {
        if (scrollView.contentOffset.y <= -self.frame.size.height)
        {
            if (self.status != UDRefreshPulling)
                [self setStatus:UDRefreshPulling];
        }
        else
        {
//            if (self.status != UDRefreshNormal)
                [self setStatus:UDRefreshNormal];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.status == UDRefreshPulling)
    {
        if ([self.superview isKindOfClass:[UITableView class]] ||
            [self.superview isKindOfClass:[UIScrollView class]])
        {
            self.status = UDRefreshLoading;
            [UIView animateWithDuration:0.3f animations:^{
                [self show]; //显示视图
            } completion:^(BOOL finished) {
                if (self.didPullingUp) self.didPullingUp(self); // 回调通知上拉刷新
            }];
        }
    }
}

#pragma mark - private methods

- (void)setEdgeInsetOnTopOfScrollView:(CGFloat)top
{
    if ([self.superview isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *scrollView = (UIScrollView*)self.superview;
        UIEdgeInsets edgeInsets = scrollView.contentInset;
        edgeInsets.top = top;
        scrollView.contentInset = edgeInsets;
        scrollView.contentOffset = CGPointMake(0, (-1)*top);
    }
}

- (void)show
{
    [self setEdgeInsetOnTopOfScrollView:self.frame.size.height];
}

- (void)hide
{
    [self setEdgeInsetOnTopOfScrollView:0.0f];
}

@end
