//
//  ViewController.h
//  Geolocation Notifications
//
//  Created by Abdul Al-Shawa on 2016-07-16.
//  Copyright © 2016 Abdul Al-Shawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ConfigureFenceViewController.h"

@interface ViewController : UIViewController <AddGeofenceDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

