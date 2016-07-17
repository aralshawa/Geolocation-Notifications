//
//  ConfigureFenceViewController.h
//  Geolocation Notifications
//
//  Created by Abdul Al-Shawa on 2016-07-16.
//  Copyright © 2016 Abdul Al-Shawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GeolocationFence.h"


@protocol AddGeofenceDelegate;


@interface ConfigureFenceViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *eventTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *radiusTextField;
@property (weak, nonatomic) IBOutlet UITextField *noteTextField;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *currLocationBtn;

@property (nonatomic) id<AddGeofenceDelegate> delegate;

@end


@protocol AddGeofenceDelegate <NSObject>

- (void)configureFenceViewController:(ConfigureFenceViewController *)controller didAddNewFenceAtCoordinate:(CLLocationCoordinate2D) coordinate withRadius:(double)radius identifier:(NSString *)uid notificationNote:(NSString *)note eventType:(GeolocationFenceEventType)eventType;

@optional
- (MKCoordinateRegion)initialRegionToBeginFenceSelection;

@end
