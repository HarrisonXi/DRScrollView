//
//  ViewController.m
//  DRScrollViewDemo
//
//  Created by HarrisonXi on 2017/11/7.
//  Copyright (c) 2017 http://harrisonxi.com/. All rights reserved.
//

#import "ViewController.h"
#import "DRScrollView.h"

@interface TestLabel : UILabel

@property (nonatomic, assign) NSUInteger order;

@end

@implementation TestLabel

- (NSString *)description
{
    return [NSString stringWithFormat:@"index: %zd (%zd)", self.dr_Index, self.order];
}

@end

@interface ViewController () <DRScrollViewDataSource>

@property (nonatomic, strong) NSArray<DRRect *> *rectArray;
@property (nonatomic, strong) DRScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"DRScrollView";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"reload"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(reloadAction:)];
    
    self.scrollView = [[DRScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.endPadding = 10;
    self.scrollView.dataSource = self;
    [self.view addSubview:self.scrollView];
    
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    NSMutableArray *rectArray = [[NSMutableArray alloc] init];
    // 1 x 5
    for (NSInteger i = 0; i < 5; i++) {
        [rectArray addObject:DRRectMake(10, 10 + i * 110 , viewWidth - 20, 100)];
    }
    // 5 x 1
    CGFloat rectWidth = (viewWidth - 10) / 5.0 - 10;
    for (NSInteger i = 0; i < 5; i++) {
        [rectArray addObject:DRRectMake(10 + (rectWidth + 10) * i , 560, rectWidth, 200)];
    }
    // 3 x 3
    rectWidth = (viewWidth - 10) / 3.0 - 10;
    for (NSInteger y = 0; y < 3; y++) {
        for (NSInteger x = 0; x < 3; x++) {
            [rectArray addObject:DRRectMake(10 + (rectWidth + 10) * x, 770 + 160 * y, rectWidth, 150)];
        }
    }
    self.rectArray = [rectArray copy];
    
    [self.scrollView reloadData];
}

- (void)reloadAction:(id)sender
{
    [self.scrollView reloadData];
}

- (NSUInteger)numberOfItemViewsInScrollView:(DRScrollView *)scrollView
{
    return self.rectArray.count;
}

- (DRRect *)scrollView:(DRScrollView *)scrollView rectForIndex:(NSUInteger)index
{
    if (index < self.rectArray.count) {
        return self.rectArray[index];
    }
    return DRRectZero;
}

- (UIView *)scrollView:(DRScrollView *)scrollView itemViewForIndex:(NSUInteger)index
{
    static NSInteger order = 0;
    BOOL isReusable = index % 6 != 0;
    TestLabel *label = isReusable ? (id)[scrollView dequeueReusableItemViewWithIdentifier:@"test"] : nil;
    if (!label) {
        label = [[TestLabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        if (isReusable) {
            label.dr_reuseIdentifier = @"test";
            label.textColor = [UIColor blueColor];
        } else {
            label.textColor = [UIColor redColor];
        }
        label.backgroundColor = [self randomColor];
        label.numberOfLines = 2;
        label.order = ++order;
    }
    label.text = [NSString stringWithFormat:@"index: %zd\n(%zd)", index, label.order];
    return label;
}

#pragma mark - Private

- (UIColor *)randomColor
{
    CGFloat red = (arc4random() % 128 / 256.0) + 0.25;
    CGFloat green = (arc4random() % 128 / 256.0) + 0.25;
    CGFloat blue = (arc4random() % 128 / 256.0) + 0.25;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
    
}

@end
