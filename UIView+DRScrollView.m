//
//  UIView+DRScrollView.m
//  DRScrollView
//
//  Created by HarrisonXi on 2017/11/6.
//  Copyright (c) 2015-2017 tmall. All rights reserved.
//  Copyright (c) 2017 http://harrisonxi.com/. All rights reserved.
//

#import "UIView+DRScrollView.h"
#import <objc/runtime.h>

@implementation UIView (DRScrollView)

- (void)setDr_reuseIdentifier:(NSString *)dr_reuseIdentifier
{
    objc_setAssociatedObject(self, @"dr_reuseIdentifier", dr_reuseIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)dr_reuseIdentifier
{
    return objc_getAssociatedObject(self, @"dr_reuseIdentifier");
}


- (void)setDr_Index:(NSUInteger)dr_Index
{
    objc_setAssociatedObject(self, @"dr_Index", @(dr_Index), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)dr_Index
{
    NSNumber *number = objc_getAssociatedObject(self, @"dr_Index");
    if (number) {
        return [number unsignedIntegerValue];
    }
    return NSUIntegerMax;
}

@end
