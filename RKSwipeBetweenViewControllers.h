//
//  RKSwipeBetweenViewControllers.h
//  RKSwipeBetweenViewControllers
//
//  Created by Richard Kim on 7/24/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol RKSwipeBetweenViewControllersDelegate <NSObject>

@end

@interface RKSwipeBetweenViewControllers : UINavigationController <UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *viewControllerArray;
@property (nonatomic, weak) id<RKSwipeBetweenViewControllersDelegate> navDelegate;
@property (nonatomic, strong) UIView *selectionBar;
@property (nonatomic, strong)UIPageViewController *pageController;
@property (nonatomic, strong)UIView *navigationView;
//菜单选项的文字数组
@property (nonatomic, strong)NSArray *buttonText;

@end
