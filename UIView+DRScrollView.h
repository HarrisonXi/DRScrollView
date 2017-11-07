//
//  UIView+DRScrollView.h
//  DRScrollView
//
//  Created by HarrisonXi on 2017/11/6.
//  Copyright (c) 2015-2017 tmall. All rights reserved.
//  Copyright (c) 2017 http://harrisonxi.com/. All rights reserved.
//

#import <UIKit/UIKit.h>

/****************************************************************
 If the view in a DRScrollView has implemented this protocol,
 the view can receive messages in reusing lifecycle.
 ****************************************************************/
@protocol  DRScrollViewCellProtocol<NSObject>

@optional

@end

/****************************************************************
 UIView category for DRScrollView.
 ****************************************************************/
@interface UIView (DRScrollView)

/**
 DRScrollView will set this property correctly.
 DO NOT modify it manually.
 */
@property (nonatomic, assign) NSUInteger dr_Index;

@property (nonatomic, copy, nullable) NSString *dr_reuseIdentifier;

@end
