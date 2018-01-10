//
//  DRScrollView.h
//  DRScrollView
//
//  Copyright (c) 2015-2017 tmall. All rights reserved.
//  Copyright (c) 2017 http://harrisonxi.com/. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+DRScrollView.h"
#import "DRRect.h"

@class DRScrollView;

/****************************************************************
 DSScrollView use this protocol to get data.
 ****************************************************************/
@protocol DRScrollViewDataSource <NSObject>

@required

- (NSUInteger)numberOfItemViewsInScrollView:(nonnull DRScrollView *)scrollView;
- (nonnull DRRect *)scrollView:(nonnull DRScrollView *)scrollView rectForIndex:(NSUInteger)index;
- (nonnull UIView *)scrollView:(nonnull DRScrollView *)scrollView itemViewForIndex:(NSUInteger)index;

@optional

/**
 If you want to calc indexs to show by yourself to improve performance,
 plase implement this method.
 */
- (nonnull NSArray<NSNumber *> *)indexsToShowFromStart:(CGFloat)start toEnd:(CGFloat)end;

@end

/****************************************************************
 DSScrollView works like a UITableView. It can reuse item views in
 it. It use rectangle (frame) to locate item views but not just
 a height property.
 ****************************************************************/
@interface DRScrollView : UIScrollView

@property (nonatomic, weak, nullable) id<DRScrollViewDataSource> dataSource;

/**
 It is used for save the original delegate of UIScrollView.
 The delegate of DRScrollView is always point to itself. When you set delegate for
 DRScrollView, it will save it in this property and forward message to this delegate.
 */
@property (nonatomic, weak, readonly, nullable) id<UIScrollViewDelegate> originalDelegate;

/**
 DRScrollView will preload some item views out of bounds. So we have not to
 do calculation in every scrollViewDidScroll: event. This property defined
 the buffer length. Default value is 20.
 DO NOT set it to a very small value.
 The item views in buffer area is not a part of visibleItemViews.
 */
@property (nonatomic, assign) CGFloat bufferLength;

/**
 DRScrollView will calc contentSize with this property.
 For vertical scrolling DRScrollView, contentSize.height is equal to bottom of
 bottom item view plus endPadding.
 */
@property (nonatomic, assign) CGFloat endPadding;

@property (nonatomic, strong, readonly, nonnull) NSArray<UIView *> *visibleItemViews;
@property (nonatomic, strong, readonly, nonnull) NSArray<NSNumber *> *indexsForVisibleItemViews;

- (NSUInteger)numberOfItemViews;
- (nullable DRRect *)rectForIndex:(NSUInteger)index;
- (nullable UIView *)itemViewForIndex:(NSUInteger)index;

//- (void)scrollToIndex:(NSUInteger)index atScrollPosition:(UITableViewScrollPosition)scrollPosition;

//- (void)removeIndexs:(nonnull NSArray<NSNumber *> *)indexs;
//- (void)insertIndexs:(nonnull NSArray<NSNumber *> *)indexs;
//- (void)moveIndex:(NSUInteger)index toIndex:(NSUInteger)newIndex;
//- (void)reloadIndexs:(nonnull NSArray<NSNumber *> *)indexs;

- (void)reloadData;

- (nullable UIView *)dequeueReusableItemViewWithIdentifier:(nonnull NSString *)identifier;

@end
