//
//  YKDragRefreshTableView.h
//  YKElectronic
//
//  Created by wei feng on 15/3/14.
//  Copyright (c) 2015年 wei feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDRefreshBaseView.h"

/**
 *  @brief 通过子类化UITableView，自定义一个带有上下刷新功能的tableview
 */
@class YKDragRefreshTableView;

/**
 *  @brief table refreshView 的数据源，定义了上下刷新视图的样式（详细定义见 UDRefreshBaseView）
 */
@protocol YKDragRefreshTableViewRefreshDataSource <NSObject>

- (UDRefreshViewStyle)refreshHeaderViewStyleInTableView:(YKDragRefreshTableView *)tableView;
- (UDRefreshViewStyle)refreshFooterViewStyleInTableView:(YKDragRefreshTableView *)tableView;

@end

/**
 *  @brief table refreshView 的委托代理, 监听上下刷新视图的 刷新事件
 */
@protocol YKDragRefreshTableViewRefreshDelegate <NSObject>

- (void)tableView:(YKDragRefreshTableView *)tableView refreshHeaderViewDidpullup:(UDRefreshBaseView *)headerView;
- (void)tableView:(YKDragRefreshTableView *)tableView refreshFooterViewDidpullDown:(UDRefreshBaseView *)footerView;

@end

@interface YKDragRefreshTableView : UITableView

@property (nonatomic, strong) UDRefreshBaseView *headerView;        ///< 上刷新视图
@property (nonatomic, strong) UDRefreshBaseView *footerView;        ///< 下刷新视图

@property (nonatomic, weak) IBOutlet id<YKDragRefreshTableViewRefreshDataSource> refreshDataSource;
@property (nonatomic, weak) IBOutlet id<YKDragRefreshTableViewRefreshDelegate> refreshDelegate;

/*******************  监听tableView的滚动事件以设置refreshview的status  *****************/
- (void)tableViewDidScroll;
- (void)tableViewDidEndDraggingWillDecelerate:(BOOL)decelerate;
- (void)tableViewDidEndDecelerating;
/*******************  需要设置UIScrollView delegate，并将其滚动事件传递进来  *****************/

/**
 *  @brief 重新设置上下refreshview的status 为 nomal
 */
- (void)resetRefreshViewStatus;

@end
