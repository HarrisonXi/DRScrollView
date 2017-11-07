//
//  DRRect.m
//  DRScrollView
//
//  Created by HarrisonXi on 2017/11/7.
//  Copyright (c) 2015-2017 tmall. All rights reserved.
//  Copyright (c) 2017 http://harrisonxi.com/. All rights reserved.
//

#import "DRRect.h"

@implementation DRRect

- (instancetype)initWithRect:(CGRect)rect
{
    if (self = [super init]) {
        self.innerRect = rect;
    }
    return self;
}

- (CGSize)size
{
    return self.innerRect.size;
}

- (CGPoint)origin
{
    return self.innerRect.origin;
}

- (CGFloat)x
{
    return self.innerRect.origin.x;
}

- (CGFloat)y
{
    return self.innerRect.origin.y;
}

- (CGFloat)width
{
    return self.innerRect.size.width;
}

- (CGFloat)height
{
    return self.innerRect.size.height;
}

- (CGFloat)top
{
    return self.innerRect.origin.y;
}

- (CGFloat)left
{
    return self.innerRect.origin.x;
}

- (CGFloat)bottom
{
    return CGRectGetMaxY(self.innerRect);
}

- (CGFloat)right
{
    return CGRectGetMaxX(self.innerRect);
}

@end
