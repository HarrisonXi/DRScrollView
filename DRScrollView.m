//
//  DRScrollView.m
//  DRScrollView
//
//  Copyright (c) 2015-2017 tmall. All rights reserved.
//  Copyright (c) 2017 http://harrisonxi.com/. All rights reserved.
//

#import "DRScrollView.h"
#import <objc/runtime.h>

@interface DRScrollView () <UIScrollViewDelegate> {
    NSArray<UIView *> *_visibleItemViews;
    NSArray<NSNumber *> *_indexsForVisibleItemViews;
}

/**
 The contentOffset at the time when we calc bufferedItemViews last time.
 */
@property (nonatomic, assign) CGPoint lastContentOffset;

@property (nonatomic, strong) NSMutableArray<UIView *> *bufferedItemViews;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *indexsForBufferedItemViews;

@property (nonatomic, strong) NSMutableArray<DRRect *> *cachedRectArray; // cached DRRect data from rectForIndex
- (void)cacheRectArray;
- (NSArray<NSNumber *> *)indexsToShowFromStart:(CGFloat)start toEnd:(CGFloat)end;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableSet *> *reusePool;
- (void)pushReusableItemView:(UIView *)view;
- (UIView *)popReusableItemViewForIdentifier:(NSString *)identifier;

@end

@implementation DRScrollView

@dynamic visibleItemViews, indexsForVisibleItemViews;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _bufferLength = 20;
        _bufferedItemViews = [NSMutableArray array];
        _indexsForBufferedItemViews = [NSMutableArray array];
        _cachedRectArray = [NSMutableArray array];
        _reusePool = [NSMutableDictionary dictionary];
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        [super setDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    _dataSource = nil;
    [super setDelegate:nil];
}

- (void)setBufferLength:(CGFloat)bufferLength
{
    _bufferLength = bufferLength > 20 ? bufferLength : 20;
}

- (void)setEndPadding:(CGFloat)endPadding
{
    _endPadding = endPadding > 0 ? endPadding : 0;
}

- (void)didScroll
{
    _visibleItemViews = nil;
    _indexsForVisibleItemViews = nil;
    
    CGFloat current = self.contentOffset.y;
    if (ABS(current - self.lastContentOffset.y) > self.bufferLength / 2) {
        CGFloat start = CGRectGetMinY(self.bounds) - self.bufferLength;
        CGFloat end = CGRectGetMaxY(self.bounds) + self.bufferLength;
        [self assembleItemViewFromStart:start toEnd:end isReload:NO];
        self.lastContentOffset = self.contentOffset;
    }
}

- (void)assembleItemViewFromStart:(CGFloat)start toEnd:(CGFloat)end isReload:(BOOL)isReload
{
    NSArray<NSNumber *> *indexsToShow = [self indexsToShowFromStart:start toEnd:end];

    // remove views from buffer
    NSMutableArray<UIView *> *viewsToRemove = [[NSMutableArray alloc] init];
    for (UIView *view in self.bufferedItemViews) {
        BOOL isToShow = [indexsToShow containsObject:@(view.dr_Index)];
        BOOL isReusable = view.dr_reuseIdentifier.length > 0;
        if (YES == isReload || NO == isToShow) {
            // remove view from buffer when:
            // 1. we are reloading data
            // 2. the view is not going to be shown
            [self.indexsForBufferedItemViews removeObject:@(view.dr_Index)];
            [viewsToRemove addObject:view];
            if (YES == isReusable) {
                // add reusable view into reuse pool and hide it
                [self pushReusableItemView:view];
                view.hidden = YES;
            } else {
                // remove view from view tree
                [view removeFromSuperview];
            }
        }
    }
    [self.bufferedItemViews removeObjectsInArray:viewsToRemove];
    
    // create or reuse views to show
    for (NSNumber *number in indexsToShow) {
        BOOL isInBuffer = [self.indexsForBufferedItemViews containsObject:number];
        if (NO == isInBuffer) {
            NSUInteger index = [number unsignedIntegerValue];
            // create or reuse view and show it
            UIView *view = [self itemViewForIndex:index];
            view.dr_Index = index;
            view.frame = self.cachedRectArray[index].innerRect;
            if (view.hidden) {
                view.hidden = NO;
            }
            if (view.superview != self) {
                if (view.superview) {
                    [view removeFromSuperview];
                }
                [self addSubview:view];
            }
            // add view into buffer
            [self.indexsForBufferedItemViews addObject:number];
            [self.bufferedItemViews addObject:view];
        }
    }
}

- (void)reloadData
{
    [self cacheRectArray];
    
    _visibleItemViews = nil;
    _indexsForVisibleItemViews = nil;
    
    CGFloat start = CGRectGetMinY(self.bounds) - self.bufferLength;
    CGFloat end = CGRectGetMaxY(self.bounds) + self.bufferLength;
    [self assembleItemViewFromStart:start toEnd:end isReload:YES];
    self.lastContentOffset = self.contentOffset;
}

- (UIView *)dequeueReusableItemViewWithIdentifier:(NSString *)identifier
{
    return [self popReusableItemViewForIdentifier:identifier];
}

#pragma mark - VisibleItemViews

- (NSArray<UIView *> *)visibleItemViews
{
    if (!_visibleItemViews) {
        CGFloat start = CGRectGetMinY(self.bounds);
        CGFloat end = CGRectGetMaxY(self.bounds);
        NSMutableArray *views = [NSMutableArray array];
        for (UIView *view in self.bufferedItemViews) {
            DRRect *rect = self.cachedRectArray[view.dr_Index];
            if (rect.bottom >= start || rect.top <= end) {
                [views addObject:view];
            }
        }
        _visibleItemViews = [views copy];
    }
    return _visibleItemViews;
}

- (NSArray<NSNumber *> *)indexsForVisibleItemViews
{
    if (!_indexsForVisibleItemViews) {
        CGFloat start = CGRectGetMinY(self.bounds);
        CGFloat end = CGRectGetMaxY(self.bounds);
        NSMutableArray *indexs = [NSMutableArray array];
        for (NSNumber *number in self.indexsForBufferedItemViews) {
            NSUInteger index = [number unsignedIntegerValue];
            DRRect *rect = self.cachedRectArray[index];
            if (rect.bottom >= start || rect.top <= end) {
                [indexs addObject:@(index)];
            }
        }
        _indexsForVisibleItemViews = [indexs copy];
    }
    return _indexsForVisibleItemViews;
}

#pragma mark - RectCachingAndSearching

- (void)cacheRectArray
{
    [self.cachedRectArray removeAllObjects];
    CGFloat maximum = 0;
    for (NSUInteger index = 0; index < [self numberOfItemViews]; index++) {
        DRRect *rect = [self rectForIndex:index];
        [self.cachedRectArray addObject:rect];
        if (rect.bottom > maximum) {
            maximum = rect.bottom;
        }
    }
    self.contentSize = CGSizeMake(self.bounds.size.width, maximum + self.endPadding);
}

- (NSArray<NSNumber *> *)indexsToShowFromStart:(CGFloat)start toEnd:(CGFloat)end
{
    if ([self.dataSource respondsToSelector:@selector(indexsToShowFromStart:toEnd:)]) {
        return [self.dataSource indexsToShowFromStart:start toEnd:end];
    }
    
    NSMutableArray *indexsToShow = [NSMutableArray array];
    for (NSUInteger index = 0; index < self.cachedRectArray.count; index++) {
        DRRect *rect = self.cachedRectArray[index];
        if (rect.bottom >= start && rect.top <= end) {
            [indexsToShow addObject:@(index)];
        }
    }
    return [indexsToShow copy];
}

#pragma mark - ReusePool

- (void)pushReusableItemView:(UIView *)view
{
    NSString *identifier = view.dr_reuseIdentifier;
    if (identifier.length > 0) {
        NSMutableSet *subPool;
        if ([self.reusePool.allKeys containsObject:identifier]) {
            subPool = self.reusePool[identifier];
        } else {
            subPool = [NSMutableSet set];
            self.reusePool[identifier] = subPool;
        }
        [subPool addObject:view];
    }
}

- (UIView *)popReusableItemViewForIdentifier:(NSString *)identifier
{
    UIView *view = nil;
    if (identifier.length > 0 && [self.reusePool.allKeys containsObject:identifier]) {
        NSMutableSet *subPool = self.reusePool[identifier];
        if (subPool.count > 0) {
            view = [subPool anyObject];
            [subPool removeObject:view];
        }
    }
    return view;
}

#pragma mark - DataSource

- (NSUInteger)numberOfItemViews
{
    if (self.dataSource) {
        return [self.dataSource numberOfItemViewsInScrollView:self];
    }
    NSAssert(NO, @"DRScrollView - numberOfItemViews: should not reach here");
    return 0;
}

- (DRRect *)rectForIndex:(NSUInteger)index
{
    if (self.dataSource) {
        return [self.dataSource scrollView:self rectForIndex:index];
    }
    NSAssert(NO, @"DRScrollView - rectForIndex: should not reach here");
    return nil;
}

- (UIView *)itemViewForIndex:(NSUInteger)index
{
    if (self.dataSource) {
        return [self.dataSource scrollView:self itemViewForIndex:index];
    }
    NSAssert(NO, @"DRScrollView - itemViewForIndex: should not reach here");
    return nil;
}

#pragma mark - UIScrollViewDelegateForwarding

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate
{
    [super setDelegate:nil];
    _originalDelegate = delegate;
    [super setDelegate:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self didScroll];
    
    if (self.originalDelegate && [self.originalDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.originalDelegate scrollViewDidScroll:scrollView];
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if (self.originalDelegate) {
        struct objc_method_description md = protocol_getMethodDescription(@protocol(UIScrollViewDelegate), aSelector, NO, YES);
        if (NULL != md.name) {
            return self.originalDelegate;
        }
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL result = [super respondsToSelector:aSelector];
    if (NO == result && self.originalDelegate) {
        struct objc_method_description md = protocol_getMethodDescription(@protocol(UIScrollViewDelegate), aSelector, NO, YES);
        if (NULL != md.name) {
            result = [self.originalDelegate respondsToSelector:aSelector];
        }
    }
    return result;
}

@end
