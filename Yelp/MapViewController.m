//
//  MapViewController.m
//  Yelp
//
//  Created by Sean Zeng on 6/19/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "MapViewController.h"
#import "Business.h"
#import "BusinessAnnotation.h"
#import "DetailViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 順序不可對調?
    [self setLocation];
    [self addAnnotations];

    self.mapView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSearchResults:) name:@"UpdateSearchResults" object:nil];
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

- (void)addAnnotations {
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    for (Business *business in self.businesses) {
        BusinessAnnotation *annotation = [[BusinessAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(business.latitude, business.longitude);
        annotation.title = business.name;
        annotation.subtitle = business.categories;
        annotation.business = business;
        [self.mapView addAnnotation:annotation];
    }
}

- (void)setLocation {
    MKCoordinateRegion region;
    region.center.latitude = [[self.region valueForKeyPath:@"center.latitude"] doubleValue];
    region.center.longitude = [[self.region valueForKeyPath:@"center.longitude"] doubleValue];
    region.span.latitudeDelta = [[self.region valueForKeyPath:@"span.latitude_delta"] doubleValue];
    region.span.longitudeDelta = [[self.region valueForKeyPath:@"span.longitude_delta"] doubleValue];
    [self.mapView setRegion:region animated:YES];
}

- (void)updateSearchResults:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"UpdateSearchResults"]) {
        [self.delegate setBusinessesForMapViewController:self];
        [self.delegate setRegionForMapViewController:self];
        [self setLocation];
        [self addAnnotations];
    }
}

#pragma mark - MKMapView delegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKPinAnnotationView *pinAnnotation = nil;
    
    if (annotation != mapView.userLocation) {
        static NSString *identifier = @"myAnnotationIdentifier";
        pinAnnotation = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (pinAnnotation == nil) {
            pinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        
        pinAnnotation.canShowCallout = YES;
        
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinAnnotation.rightCalloutAccessoryView = infoButton;
    }
    
    return pinAnnotation;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    Business *business = [(BusinessAnnotation *)view.annotation business];
    
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    detailViewController.business = business;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view NS_AVAILABLE(10_9, 4_0) {
    [mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
}

@end
