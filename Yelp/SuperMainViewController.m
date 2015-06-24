//
//  SuperMainViewController.m
//  Yelp
//
//  Created by Sean Zeng on 6/23/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "SuperMainViewController.h"
#import "MainViewController.h"
#import "MapViewController.h"

@interface SuperMainViewController () <UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)onSwitchLayout:(id)sender;

@property (strong, nonatomic) MainViewController *mainViewController;
@property (strong, nonatomic) MapViewController *mapViewController;

@end

@implementation SuperMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    [self addChildViewController:self.mainViewController];
    
    //self.navigationController.delegate = mainViewController;
    self.navigationController.delegate = self;
    
    // not work?
    //self.contentView = mainViewController.view;
    
    self.mainViewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:self.mainViewController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Navigation controller delegate methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"willShowViewController");
    //self.navigationItem.titleView = ((UIViewController *)[viewController.childViewControllers objectAtIndex:0]).navigationItem.titleView;
    //self.navigationItem.leftBarButtonItem = ((UIViewController *)[viewController.childViewControllers objectAtIndex:0]).navigationItem.leftBarButtonItem;
    //self.navigationItem.rightBarButtonItem = ((UIViewController *)[viewController.childViewControllers objectAtIndex:0]).navigationItem.rightBarButtonItem;
}

- (IBAction)onSwitchLayout:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegmentIndex = segmentedControl.selectedSegmentIndex;
    
    if (selectedSegmentIndex == 1) {
        if (self.mapViewController == nil) {
            self.mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
            [self addChildViewController:self.mapViewController];
        }
        self.mapViewController.businesses = self.mainViewController.businesses;
        self.mapViewController.region = self.mainViewController.region;
        self.mapViewController.delegate = (id<MapViewControllerDelegate>)self.mainViewController;
        self.mapViewController.view.frame = self.contentView.bounds;
        [self.contentView addSubview:self.mapViewController.view];
    }
    else {
        [self.contentView addSubview:self.mainViewController.view];
    }
}

@end
