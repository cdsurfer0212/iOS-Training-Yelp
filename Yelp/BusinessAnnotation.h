//
//  BusinessAnnotation.h
//  Yelp
//
//  Created by Sean Zeng on 6/23/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Business.h"

@interface BusinessAnnotation : MKPointAnnotation

@property (nonatomic, strong) Business *business;

@end
