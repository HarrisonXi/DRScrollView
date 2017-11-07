//
//  DRRect.h
//  DRScrollView
//
//  Created by HarrisonXi on 2017/11/7.
//  Copyright (c) 2015-2017 tmall. All rights reserved.
//  Copyright (c) 2017 http://harrisonxi.com/. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DRRectMake(x, y, w, h) [[DRRect alloc] initWithRect:CGRectMake(x, y, w, h)]
#define DRRectZero [[DRRect alloc] init]

@interface DRRect : NSObject

@property (nonatomic, assign) CGRect innerRect;

@property (nonatomic, assign, readonly) CGSize size;
@property (nonatomic, assign, readonly) CGPoint origin;
@property (nonatomic, assign, readonly) CGFloat x;
@property (nonatomic, assign, readonly) CGFloat y;
@property (nonatomic, assign, readonly) CGFloat width;
@property (nonatomic, assign, readonly) CGFloat height;
@property (nonatomic, assign, readonly) CGFloat left;
@property (nonatomic, assign, readonly) CGFloat top;
@property (nonatomic, assign, readonly) CGFloat bottom;
@property (nonatomic, assign, readonly) CGFloat right;

- (nonnull instancetype)initWithRect:(CGRect)rect;

@end
