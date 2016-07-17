//
//  ViewController.m
//  Geolocation Notifications
//
//  Created by Abdul Al-Shawa on 2016-07-16.
//  Copyright © 2016 Abdul Al-Shawa. All rights reserved.
//

#import "ViewController.h"
#import "ConfigureFenceViewController.h"
#import "GeolocationFence.h"

@interface ViewController ()

@end

@implementation ViewController {
	NSMutableArray <GeolocationFence *>* _geofences;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_geofences = [NSMutableArray array];
	
	[self unarchieveGeofences];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"addGeofence"]) {
		UINavigationController *navController = segue.destinationViewController;
		ConfigureFenceViewController *configurationVC = navController.viewControllers.firstObject;
		
		configurationVC.delegate = self;
	}
}

- (void)addGeofence:(GeolocationFence *)fence
{
	if (fence != nil) {
		[_geofences addObject:fence];
		[self.mapView addAnnotation:fence];
		[self addRadiusOverlayForGeofence:fence];
		self.title = [NSString stringWithFormat:@"Geofences (%zd)", _geofences.count];
	}
}

- (void)removeGeofence:(GeolocationFence *)fence
{
	if (fence != nil) {
		[_geofences removeObject:fence];
		[self.mapView removeAnnotation:fence];
		[self removeRadiusOverlayForGeofence:fence];
		self.title = [NSString stringWithFormat:@"Geofences (%zd)", _geofences.count];
	}
}

- (void)addRadiusOverlayForGeofence:(GeolocationFence *)fence {
	[self.mapView addOverlay:[MKCircle circleWithCenterCoordinate:fence.coordinate radius:fence.radius]];
}

- (void)removeRadiusOverlayForGeofence:(GeolocationFence *)fence {
	for (MKCircle *overlay in [self.mapView overlays]) {
		if (overlay.coordinate.latitude == fence.coordinate.latitude && overlay.coordinate.longitude == fence.coordinate.longitude && overlay.radius == fence.radius) {
			[self.mapView removeOverlay:overlay];
			break;
		}
	}
}

#pragma mark - Archieving
#define kGeofenceListKey @"kGeofenceListKey"

- (void)archieveGeofences
{
	NSMutableArray *itemsToArchieve = [NSMutableArray array];
	
	for (GeolocationFence *fence in _geofences) {
		NSData *dataToArchieve = [NSKeyedArchiver archivedDataWithRootObject:fence];
		[itemsToArchieve addObject:dataToArchieve];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:itemsToArchieve forKey:kGeofenceListKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)unarchieveGeofences
{
	NSArray *archievedFences = [[NSUserDefaults standardUserDefaults] arrayForKey:kGeofenceListKey];
	
	for (NSData *savedItem in archievedFences) {
		[self addGeofence:[NSKeyedUnarchiver unarchiveObjectWithData:savedItem]];
	}
}

#pragma mark - <MKMapViewDelegate>
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	static NSString *annotationViewIden = @"annotationViewIden";
	MKPinAnnotationView *annotationView = nil;
	
	if ([annotation isKindOfClass:[GeolocationFence class]]) {
		annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewIden];
		if (annotationView == nil) {
			annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewIden];
			annotationView.canShowCallout = YES;
			
			UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			removeBtn.frame = CGRectMake(0, 0, 23, 23);
			[removeBtn setImage:[UIImage imageNamed:@"DeleteFence"] forState:UIControlStateNormal];
			annotationView.leftCalloutAccessoryView = removeBtn;
		} else {
			annotationView.annotation = annotation;
		}
	}
	
	return annotationView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
	if ([overlay isKindOfClass:[MKCircle class]]) {
		MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
		renderer.lineWidth = 1.f;
		renderer.strokeColor = [UIColor purpleColor];
		renderer.fillColor = [[UIColor purpleColor] colorWithAlphaComponent:0.4f];
		
		return renderer;
	}
	
	return nil;
}

- (IBAction)zoomToCurrentLocation:(id)sender
{
	CLLocationCoordinate2D coordinate = self.mapView.userLocation.location.coordinate;
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 1000);
	[self.mapView setRegion:region animated:YES];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	if ([view.annotation isKindOfClass:[GeolocationFence class]]) {
		[self removeGeofence:(GeolocationFence *)view.annotation];
		[self archieveGeofences];
	}
}

#pragma mark - <AddGeofenceDelegate>
- (void)configureFenceViewController:(ConfigureFenceViewController *)controller didAddNewFenceAtCoordinate:(CLLocationCoordinate2D) coordinate withRadius:(double)radius identifier:(NSString *)uid notificationNote:(NSString *)note eventType:(GeolocationFenceEventType)eventType
{
	[controller dismissViewControllerAnimated:YES completion:NULL];
	
	GeolocationFence *newFence = [[GeolocationFence alloc] initWithCoordinate:coordinate radius:radius identifier:uid note:note eventType:eventType];
	[self addGeofence:newFence];
	[self archieveGeofences];
}


@end
