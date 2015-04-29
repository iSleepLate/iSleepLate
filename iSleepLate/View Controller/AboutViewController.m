//
//  AboutViewController.m
//  iSleepLate
//
//  Created by David Neubauer on 4/29/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "AboutViewController.h"
#import "SWRevealViewController.h"

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sideMenuButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.sideMenuButton setTarget: self.revealViewController];
        [self.sideMenuButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

@end
