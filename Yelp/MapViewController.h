//
//  MapViewController.h
//  Yelp
//
//  Created by Sean Zeng on 6/19/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapViewController;

@protocol MapViewControllerDelegate <NSObject>

- (void)setBusinessesForMapViewController:(MapViewController *)mapViewController;
- (void)setRegionForMapViewController:(MapViewController *)mapViewController;

@end

@interface MapViewController : UIViewController

@property (nonatomic, strong) NSArray *businesses;
@property (nonatomic, strong) NSDictionary *region;
@property (nonatomic, weak) id<MapViewControllerDelegate> delegate;

@end
