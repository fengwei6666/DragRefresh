//
//  UDRefreshBaseView.h
//  UDDragRefreshDemo
//
//  Created by wei feng on 3/2/15.
//  Copyright (c) 2015 wei feng. All rights reserved.
//

#import <UIKit/UIKit.h>

/** UDRefreshBaseView的样式及回调方法 */
@class UDRefreshBaseView;

/** 上拉，下拉刷新支持的视图样式,现在只写了一种常用样式(normal)，便于后期扩展 */
typedef NS_ENUM(NSInteger, UDRefreshViewStyle)
{
    UDRefreshViewStyleNormal = 1,
    UDRefreshViewStyleSimple,
    UDRefreshViewStyleZ800
};

/** 上拉，下拉刷新的状态 */
typedef NS_ENUM(NSInteger, UDRefreshStatus)
{
    UDRefreshNormal = 0,    ///< 默认状态
    UDRefreshPulling,       ///< 正在上拉/下拉
    UDRefreshLoading,       ///< 正在加载数据
    UDRefreshLoaded,        ///< 数据加载完成
    UDRefreshAllLoaded      ///< 所有数据加载完成
};

typedef void (^UDDidRefreshViewPullingUp)(UDRefreshBaseView *refreshView);
typedef void (^UDDidRefreshViewPullingDown)(UDRefreshBaseView *refreshView);

@interface UDRefreshBaseView : UIView
{
    UDRefreshStatus _status;
}

@property (nonatomic, assign) UDRefreshStatus status;                   ///< 所属状态
@property (nonatomic, copy) NSString *identifiler;                      ///< 唯一标示，可以用来表示最后更新时间
@property (nonatomic, copy) UDDidRefreshViewPullingUp didPullingUp;     ///< 顶部刷新视图拉起
@property (nonatomic, copy) UDDidRefreshViewPullingDown didPullingDown; ///< 底部刷新视图拉起

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidSizeChanged:(CGSize)size;

@end
