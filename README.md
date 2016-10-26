# RKSwipeBetweenViewControllers
修改之后可能更符合国人的需求，使用起来也还好。具体使用如下：
#import "RKSwipeBetweenViewControllers.h"
    //初始化代码
    UIPageViewController *pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    RKSwipeBetweenViewControllers *nav = [[RKSwipeBetweenViewControllers alloc]initWithRootViewController:pageController];
    
    UIViewController *vc1 = [[UIViewController alloc] init];
    vc1.view.backgroundColor = [UIColor redColor];
    UIViewController *vc2 = [[UIViewController alloc] init];
    vc2.view.backgroundColor = [UIColor greenColor];
    UIViewController *vc3 = [[UIViewController alloc] init];
    vc3.view.backgroundColor = [UIColor blueColor];
    
    [nav.viewControllerArray addObjectsFromArray:@[vc1,vc2,vc3]];
    nav.buttonText = @[@"111",@"222",@"333"];
这样就OK了，如要修改，可直接修改内部对应注释的代码。更多问题可联系邮箱：1966767119@qq.com
viewcontrollers之间做切换操作，对开源代码加中文注释及做了部分修改，希望适合国人使用，
