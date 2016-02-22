//
//  UDRefreshBaseView.m
//  UDDragRefreshDemo
//
//  Created by wei feng on 3/2/15.
//  Copyright (c) 2015 wei feng. All rights reserved.
//

#import "UDRefreshBaseView.h"

@implementation UDRefreshBaseView

@synthesize status = _status;
@synthesize identifiler = _identifiler;
@synthesize didPullingUp = _didPullingUp;
@synthesize didPullingDown = _didPullingDown;

- (void)dealloc
{
    //
}

- (NSString *)identifiler
{
    if (_identifiler == nil)
    {
        _identifiler = [NSUUID UUID].UUIDString;
    }
    return _identifiler;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - public methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //
}

- (void)scrollViewDidSizeChanged:(CGSize)size
{
    //
}

@end
