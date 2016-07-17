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
	CLLocationManager *_locationManager;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_geofences = [NSMutableArray array];
	
	_locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
	[_locationManager requestAlwaysAuthorization];
	
	[self unarchieveGeofences];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"addGeofence"] || [segue.identifier isEqualToString:@"updateGeofence"]) {
		UINavigationController *navController = segue.destinationViewController;
		ConfigureFenceViewController *configurationVC = navController.viewControllers.firstObject;
		
		configurationVC.delegate = self;
		
		if ([sender isKindOfClass:[GeolocationFence class]]) {
			[configurationVC setToPresentDetailsForGeofence:sender];
		}
	}
}

- (void)addGeofence:(GeolocationFence *)fence
{
	if (fence != nil) {
		[_geofences addObject:fence];
		[self.mapView addAnnotation:fence];
		[self addRadiusOverlayForGeofence:fence];
		[self updateGeofenceCount];
	}
}

- (void)removeGeofence:(GeolocationFence *)fence
{
	if (fence != nil) {
		[_geofences removeObject:fence];
		[self.mapView removeAnnotation:fence];
		[self removeRadiusOverlayForGeofence:fence];
		[self updateGeofenceCount];
	}
}

- (void)updateGeofenceCount
{
	self.title = [NSString stringWithFormat:@"Geofences (%zd)", _geofences.count];
	
	// Resource Limitation: Core Location restricts the number of registered geofences to a maximum of 20 per app
	self.navigationItem.rightBarButtonItem.enabled = (_geofences.count < 20);
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
const NSInteger DELETE_BTN_TAG = 0;
const NSInteger DETAIL_BTN_TAG = 1;

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
			removeBtn.tag = DELETE_BTN_TAG;
			removeBtn.frame = CGRectMake(0, 0, 23, 23);
			[removeBtn setImage:[UIImage imageNamed:@"DeleteFence"] forState:UIControlStateNormal];
			annotationView.leftCalloutAccessoryView = removeBtn;
			
			UIButton *detailDisclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			detailDisclosure.tag = DETAIL_BTN_TAG;
			annotationView.rightCalloutAccessoryView = detailDisclosure;
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
		if (control.tag == DELETE_BTN_TAG) {
			// Delete fence
			[self stopMonitoringGeolocationFence:(GeolocationFence *)view.annotation];
			[self removeGeofence:(GeolocationFence *)view.annotation];
			[self archieveGeofences];
		} else if (control.tag == DETAIL_BTN_TAG) {
			// Show fence details
			[self performSegueWithIdentifier:@"updateGeofence" sender:view.annotation];
		}
	}
}

#pragma mark - CLLocationManager
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	self.mapView.showsUserLocation = (status == kCLAuthorizationStatusAuthorizedAlways);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
	NSLog(@"Monitoring did fail for region with ID %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"Location Manager did fail with error %@", error);
}

#pragma mark - <AddGeofenceDelegate>
- (void)configureFenceViewController:(ConfigureFenceViewController *)controller didAddNewFenceAtCoordinate:(CLLocationCoordinate2D) coordinate withRadius:(double)radius identifier:(NSString *)uid notificationNote:(NSString *)note eventType:(GeolocationFenceEventType)eventType
{
	[controller dismissViewControllerAnimated:YES completion:NULL];
	
	CLLocationDistance clampedRadius = (radius > _locationManager.maximumRegionMonitoringDistance) ? _locationManager.maximumRegionMonitoringDistance : radius;
	
	GeolocationFence *newFence = [[GeolocationFence alloc] initWithCoordinate:coordinate radius:clampedRadius identifier:uid note:note eventType:eventType];
	[self addGeofence:newFence];
	
	[self beginMonitoringGeolocationFence:newFence];
	
	[self archieveGeofences];
}

- (MKCoordinateRegion)initialRegionToBeginFenceSelection
{
	return self.mapView.region;
}

#pragma mark - Geolocation Regions
- (CLCircularRegion *)circularRegionForGeolocationFence:(GeolocationFence *)fence
{
	CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:fence.coordinate radius:fence.radius identifier:fence.uuid];
	
	region.notifyOnEntry = (fence.eventType & GeolocationFenceEventTypeEntry);
	region.notifyOnExit = (fence.eventType & GeolocationFenceEventTypeExit);
	
	return region;
}

- (void)beginMonitoringGeolocationFence:(GeolocationFence *)fence
{
	if (![CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Geofencing is not an available feature of on this device." preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:NULL];
		
		[alertController addAction:alertAction];
		
		[self presentViewController:alertController animated:YES completion:NULL];
	} else {
		if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
			UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invalid Permissions" message:@"Please grant the application permissions to your device's location in order to recieve notifications." preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:NULL];
			
			[alertController addAction:alertAction];
			
			[self presentViewController:alertController animated:YES completion:NULL];
		}
		
		[_locationManager startMonitoringForRegion:[self circularRegionForGeolocationFence:fence]];
	}
}

- (void)stopMonitoringGeolocationFence:(GeolocationFence *)fence
{
	for (CLRegion *region in _locationManager.monitoredRegions) {
		if ([region.identifier isEqualToString:fence.uuid]) {
			[_locationManager stopMonitoringForRegion:region];
		}
	}
}

@end
