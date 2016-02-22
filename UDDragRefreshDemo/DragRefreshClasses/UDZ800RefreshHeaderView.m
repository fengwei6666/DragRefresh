//
//  UDZ800RefreshHeaderView.m
//  UDDragRefreshDemo
//
//  Created by wei feng on 3/3/15.
//  Copyright (c) 2015 wei feng. All rights reserved.
//

#import "UDZ800RefreshHeaderView.h"

@interface UDZ800RefreshHeaderView()
{
    UIImageView *_adImageView;              ///< 显示广告条
    UIImageView *_loadingImageView;         ///< 引导加载的icon
    UIActivityIndicatorView *_loadingAIView;///< 菊花
    UILabel *_textLabel;                    ///< 引导加载的文字
}

@end

#define kADImageViewHeight  20
#define kLDImageViewHeight 30
#define kTopSpace 20

@implementation UDZ800RefreshHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = kLDImageViewHeight + kTopSpace * 2; // 视图的高度
        self.frame = CGRectMake(0, - height, width, height);
    }
    return self;
}

- (void)setPropertyForLabel:(UILabel*)label
{
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont systemFontOfSize:13]];
    [label setTextColor:[UIColor lightGrayColor]];
    [label setShadowColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    [label setShadowOffset:CGSizeMake(0.0f, 1.0f)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /* 广告图片 */
    if (_adImageView == nil)
    {
        CGFloat height = kADImageViewHeight;
        CGRect frame = CGRectMake(0, -height, self.frame.size.width, height);
        _adImageView = [[UIImageView alloc] initWithFrame:frame];
        [_adImageView setContentMode:UIViewContentModeScaleAspectFit];
        [_adImageView setImage:[UIImage imageNamed:@"temp.png"]];
        [self addSubview:_adImageView];
    }
    
    /* 加载的提示图片 */
    if (_loadingImageView == nil)
    {
        CGFloat width = kLDImageViewHeight;
        CGRect frame = CGRectMake((self.frame.size.width - width) / 2 - 50, CGRectGetHeight(self.frame)/2 - width/2, width, width);
        _loadingImageView = [[UIImageView alloc] initWithFrame:frame];
        [_loadingImageView setContentMode:UIViewContentModeScaleAspectFit];
        [_loadingImageView setImage:[UIImage imageNamed:@"arrow_new.png"]];
        [self addSubview:_loadingImageView];
    }
    
    /* 加载的进度提示 */
    if (_loadingAIView == nil)
    {
        CGFloat width = 20.0f;
        CGFloat y = _loadingImageView.frame.origin.y + (_loadingImageView.frame.size.height - width) / 2;
        CGRect frame = CGRectMake(_loadingImageView.frame.origin.x + (_loadingImageView.frame.size.width - width) / 2, y, width, width);
        _loadingAIView = [[UIActivityIndicatorView alloc] initWithFrame:frame];
        [_loadingAIView setCenter:_loadingImageView.center];
        [_loadingAIView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_loadingAIView];
    }
    
    /* 加载的文字信息 */
    if (_textLabel == nil)
    {
        CGFloat x = CGRectGetMaxX(_loadingImageView.frame) + 10;
        CGFloat width = self.frame.size.width - x - 50;
        CGRect rect = CGRectMake(x, CGRectGetHeight(self.frame)/2 - 10, width, 20);
        _textLabel = [[UILabel alloc] initWithFrame:rect];
        [_textLabel setText:@"下拉即可刷新"];
        [self setPropertyForLabel:_textLabel];
        [self addSubview:_textLabel];
    }
}

- (void)setStatus:(UDRefreshStatus)status
{
    switch (status)
    {
        case UDRefreshNormal:
        {
            _textLabel.text = @"下拉即可刷新";
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
            _textLabel.text = @"加载成功";
            [_loadingAIView stopAnimating];
            [_loadingImageView setHidden:NO];   //可以在这里给引导image设置一个打勾的图案
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.3f animations:^{
                    [self hide]; //加载完成，隐藏
                } completion:^(BOOL finished) {
                    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:self.identifiler];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self setStatus:UDRefreshNormal];
                }];
            });
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
