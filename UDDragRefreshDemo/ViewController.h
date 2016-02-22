//
//  ViewController.h
//  UDDragRefreshDemo
//
//  Created by wei feng on 3/2/15.
//  Copyright (c) 2015 wei feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

/**
 *  @brief 重置上下刷新视图的样式
 */
- (void)resetRefreshViewsStatus;

/**
 *  @brief 分页从服务器下载数据
 *
 *  @param pageNumber 页码
 */
- (void)loadDataFromServer:(NSInteger )pageNumber;

@end

