//
//  RKSwipeBetweenViewControllers.m
//  RKSwipeBetweenViewControllers
//
//  Created by Richard Kim on 7/24/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for regular updates

#import "RKSwipeBetweenViewControllers.h"

#define RGB(r, g, b)    [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]
#define RGBA(r, g, b, a)    [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:a]
//横向滚动条的纵坐标
CGFloat SELECTOR_Y_BUFFER = 42.5;
//横向滚动条的高度
CGFloat SELECTOR_HEIGHT = 1.5;
//按钮的高度
CGFloat BUTTON_HEIGHT = 42.5;
//按钮的宽度
CGFloat BUTTON_WIDTH = 60.0;
//按钮之间的间距
CGFloat BUTTON_BETWEEN_SPACE = 60.0;
@interface RKSwipeBetweenViewControllers ()

@property (nonatomic) UIScrollView *pageScrollView;
@property (nonatomic) NSInteger currentPageIndex;
@property (nonatomic) BOOL isPageScrollingFlag; 
//是否加载过此页面的标识符
@property (nonatomic) BOOL hasAppearedFlag;

@end

@implementation RKSwipeBetweenViewControllers
@synthesize viewControllerArray;
//横向滚动条
@synthesize selectionBar;
@synthesize pageController;
@synthesize navigationView;
@synthesize buttonText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.navigationBar.barTintColor = [UIColor colorWithRed:0.01 green:0.05 blue:0.06 alpha:1]; //%%% bartint
    self.navigationBar.barTintColor = RGB(248, 248, 248);
    self.navigationBar.translucent = NO;
    viewControllerArray = [[NSMutableArray alloc]init];
    self.currentPageIndex = 0;
    self.isPageScrollingFlag = NO;
    self.hasAppearedFlag = NO;
}

#pragma mark Customizables

//%%% color of the status bar
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
//    return UIStatusBarStyleDefault;
}

//菜单页面的设置
-(void)setupSegmentButtons {
    navigationView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.navigationBar.frame.size.height)];
    NSInteger numControllers = [viewControllerArray count];
    
    if (!buttonText) {
         buttonText = [[NSArray alloc]initWithObjects: @"first",@"second",@"third",@"fourth",@"etc",@"etc",@"etc",@"etc",nil]; //%%%buttontitle
    }
    
    CGFloat left = (self.view.frame.size.width-BUTTON_BETWEEN_SPACE*(numControllers-1)-BUTTON_WIDTH*numControllers)*0.5;
    for (int i = 0; i<numControllers; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(left+i*(BUTTON_BETWEEN_SPACE+BUTTON_WIDTH), 0,BUTTON_WIDTH, BUTTON_HEIGHT)];
        [navigationView addSubview:button];
        //为按钮加tag,后面绑定事件用得到（很重要）
        button.tag = i;
        
        [button addTarget:self action:@selector(tapSegmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:RGBA(51, 51, 51,0.4) forState:UIControlStateNormal];
        [button setTitleColor:RGB(51, 51, 51) forState:UIControlStateSelected];
        //第一个默认选中
        if (i == 0) {
            button.selected = YES;
        }
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitle:[buttonText objectAtIndex:i] forState:UIControlStateNormal]; //%%%buttontitle
    }
    
    pageController.navigationController.navigationBar.topItem.titleView = navigationView;
    
    [self setupSelector];
}


// 设置横向滚动条
-(void)setupSelector {
    NSInteger numControllers = [viewControllerArray count];
    CGFloat left = (self.view.frame.size.width-BUTTON_BETWEEN_SPACE*(numControllers-1)-BUTTON_WIDTH*numControllers)*0.5;
    selectionBar = [[UIView alloc]initWithFrame:CGRectMake(left, SELECTOR_Y_BUFFER,BUTTON_WIDTH, SELECTOR_HEIGHT)];
    selectionBar.backgroundColor = RGB(51, 51, 51);
    [navigationView addSubview:selectionBar];
}


#pragma mark Setup

-(void)viewWillAppear:(BOOL)animated {
    if (!self.hasAppearedFlag) {
        [self setupPageViewController];
        [self setupSegmentButtons];
        self.hasAppearedFlag = YES;
    }
}

//初始化UIPageViewController
-(void)setupPageViewController {
    //获取UIPageViewController
    pageController = (UIPageViewController*)self.topViewController;
    pageController.delegate = self;
    pageController.dataSource = self;
    //设置首个页面的viewcontroller
    [pageController setViewControllers:@[[viewControllerArray objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self syncScrollView];
}

//将UIPageViewController的scrollview的代理设置在本类，方便处理滚动事件
-(void)syncScrollView {
    for (UIView* view in pageController.view.subviews){
        if([view isKindOfClass:[UIScrollView class]]) {
            self.pageScrollView = (UIScrollView *)view;
            self.pageScrollView.delegate = self;
        }
    }
}

#pragma mark Movement

//点击按钮事件的捕获
-(void)tapSegmentButtonAction:(UIButton *)button {
    
    if (!self.isPageScrollingFlag) {
        
        NSInteger tempIndex = self.currentPageIndex;
        
        __weak typeof(self) weakSelf = self;
        
        //判断点击的是当前按钮的左侧还是右侧
        if (button.tag > tempIndex) {
            
            //从左向右依次滚动
            for (int i = (int)tempIndex+1; i<=button.tag; i++) {
                [pageController setViewControllers:@[[viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL complete){
                    
                    //%%% if the action finishes scrolling (i.e. the user doesn't stop it in the middle),
                    //then it updates the page that it's currently on
                    if (complete) {
                        [weakSelf updateCurrentPageIndex:i];
                    }
                }];
            }
        }
        
        //从右向左依次滚动
        else if (button.tag < tempIndex) {
            for (int i = (int)tempIndex-1; i >= button.tag; i--) {
                [pageController setViewControllers:@[[viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL complete){
                    if (complete) {
                        [weakSelf updateCurrentPageIndex:i];
                    }
                }];
            }
        }
    }
}

//更新currentPageIndex
-(void)updateCurrentPageIndex:(int)newIndex {
    NSInteger numControllers = [viewControllerArray count];
    CGFloat left = (self.view.frame.size.width-BUTTON_BETWEEN_SPACE*(numControllers-1)-BUTTON_WIDTH*numControllers)*0.5;
    
    self.currentPageIndex = newIndex;
    [self updateBtnStatus:newIndex];
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat selectionBarLeft = left+newIndex*(BUTTON_BETWEEN_SPACE+BUTTON_WIDTH);
        selectionBar.frame = CGRectMake(selectionBarLeft, selectionBar.frame.origin.y, selectionBar.frame.size.width, selectionBar.frame.size.height);
        
    }];
}
-(void)updateBtnStatus:(NSInteger)index
{
    for (UIView *view in [navigationView subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton*)view;
            if (btn.tag == index) {
                btn.selected = YES;
            }else{
                btn.selected = NO;
            }
        }
        
        
    }
}
//页面滚动事件的捕获，更新横向滚动条的坐标
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //向右滚动是正值，向左是负值
    CGFloat xFromCenter = self.view.frame.size.width-scrollView.contentOffset.x;
    NSInteger numControllers = [viewControllerArray count];
    CGFloat left = (self.view.frame.size.width-BUTTON_BETWEEN_SPACE*(numControllers-1)-BUTTON_WIDTH*numControllers)*0.5;
    
    //滚动前的选中按钮的横坐标
    NSInteger xCoor = left+(BUTTON_BETWEEN_SPACE+BUTTON_WIDTH)*self.currentPageIndex;
    //滚动的距离（相对在导航页）
    CGFloat distance = xFromCenter*(BUTTON_BETWEEN_SPACE+BUTTON_WIDTH)/self.view.frame.size.width;
    selectionBar.frame = CGRectMake(xCoor-distance, selectionBar.frame.origin.y, selectionBar.frame.size.width, selectionBar.frame.size.height);
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [viewControllerArray indexOfObject:viewController];

    if ((index == NSNotFound) || (index == 0)) {
        return nil;
    }
    
    index--;
    return [viewControllerArray objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [viewControllerArray indexOfObject:viewController];

    if (index == NSNotFound) {
        return nil;
    }
    index++;
    
    if (index == [viewControllerArray count]) {
        return nil;
    }
    return [viewControllerArray objectAtIndex:index];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        self.currentPageIndex = [viewControllerArray indexOfObject:[pageViewController.viewControllers lastObject]];
        //更新按钮选中状态
        [self updateBtnStatus:self.currentPageIndex];
    }
}

#pragma mark - Scroll View Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isPageScrollingFlag = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isPageScrollingFlag = NO;
}

@end
