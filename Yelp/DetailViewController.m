//
//  DetailViewController.m
//  Yelp
//
//  Created by Sean Zeng on 6/19/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "DetailViewController.h"
#import "BusinessCell.h"
#import "FXBlurView.h"
#import <MapKit/MapKit.h>


@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *descriptionView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation DetailViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"init DetailViewController");
        self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(_business.latitude, _business.longitude);
    annotation.title = _business.name;
    annotation.subtitle = _business.categories;
    [self.mapView addAnnotation:annotation];
    
    MKCoordinateRegion region;
    region.center.latitude = self.business.latitude;
    region.center.longitude = self.business.longitude;
    region.span.latitudeDelta = 0.005f;
    region.span.longitudeDelta = 0.005f;
    [self.mapView setRegion:region animated:YES];
    
    BusinessCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"BusinessCell" owner:self options:nil] firstObject];
    cell.business = self.business;
    [self.descriptionView addSubview:cell];
    
    FXBlurView *fxBlurView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, 600, 86)];
    fxBlurView.blurRadius = 100;
    fxBlurView.dynamic = NO;
    fxBlurView.tintColor = [UIColor clearColor];
    [self.mapView addSubview:fxBlurView];
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

@end
