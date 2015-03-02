//
//  AlarmPageViewController.m
//  iSleepLate
//
//  Created by David Neubauer on 3/1/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "AlarmPageViewController.h"
#import "ViewController.h"

@interface AlarmPageViewController () <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *colors;

@end

@implementation AlarmPageViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // initialize the UIPageViewController
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.view.frame = self.view.bounds;
    
    // array of colors (for demo purposes)
    self.colors = @[[UIColor redColor], [UIColor whiteColor], [UIColor blueColor]];
    
    // configure the pageViewController's first viewController to display
    ViewController *viewController = [[ViewController alloc] init];
    viewController.view.backgroundColor = self.colors[0];
    viewController.indexNumber = 0;
    
    [self.pageViewController setViewControllers:@[viewController]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
    
    // make the page view controller the primary view controller for this screen
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

#pragma mark - Private Methods

// here I imagine we have an array of 'alarm' objects or something and
// initiating a new 'AlarmViewController' based on that data and returning it
- (ViewController *)viewControllerAtIndex:(NSUInteger)index
{
    ViewController *viewController = [[ViewController alloc] init];
    viewController.view.backgroundColor = self.colors[index];
    viewController.indexNumber = index;
    
    return viewController;
}

#pragma mark - Protocol Conformance

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index  = ((ViewController *)viewController).indexNumber;
    if (index-- == 0) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index  = ((ViewController *)viewController).indexNumber;
    if (index++ == self.colors.count - 1) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

@end
