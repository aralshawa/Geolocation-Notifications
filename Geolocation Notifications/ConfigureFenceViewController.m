//
//  ConfigureFenceViewController.m
//  Geolocation Notifications
//
//  Created by Abdul Al-Shawa on 2016-07-16.
//  Copyright © 2016 Abdul Al-Shawa. All rights reserved.
//

#import "ConfigureFenceViewController.h"

@interface ConfigureFenceViewController () <MKMapViewDelegate>

@end

@implementation ConfigureFenceViewController {
	BOOL _presentingDetails;
	GeolocationFence *_existingFence;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (_presentingDetails) {
		// Presenting details pane - configure UI and disable interaction
		self.navigationItem.rightBarButtonItems = @[self.currLocationBtn];
		
		self.eventTypeSegmentedControl.selectedSegmentIndex = (_existingFence.eventType & GeolocationFenceEventTypeEntry) ? 0 : 1;
		self.radiusTextField.text = [NSString stringWithFormat:@"%.2f", _existingFence.radius];
		self.noteTextField.text = _existingFence.note;
		[self.mapView setRegion:MKCoordinateRegionMakeWithDistance(_existingFence.coordinate, 2 * _existingFence.radius, 2 * _existingFence.radius)];
		
		self.eventTypeSegmentedControl.enabled = NO;
		self.radiusTextField.enabled = NO;
		self.noteTextField.enabled = NO;
		self.mapView.scrollEnabled = NO;
		self.mapView.zoomEnabled = NO;
	} else {
		// Presenting add new marker pane
		self.navigationItem.rightBarButtonItems = @[self.addBtn, self.currLocationBtn];
		self.addBtn.enabled = NO;
		
		if ([self.delegate respondsToSelector:@selector(initialRegionToBeginFenceSelection)]) {
			[self.mapView setRegion:[self.delegate initialRegionToBeginFenceSelection]];
		}
	}
	
	self.mapView.delegate = self;
	
	// Hide the remaining empty rows of the table view
	self.tableView.tableFooterView = [UIView new];
}

- (IBAction)textFieldDidEdit:(UITextField *)sender {
	self.addBtn.enabled = self.radiusTextField.text.length > 0 && self.noteTextField.text.length > 0;
}

- (IBAction)didCancel:(id)sender {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)addFence:(id)sender {
	CLLocationCoordinate2D coordinate = self.mapView.centerCoordinate;
	double radius = [self.radiusTextField.text doubleValue];
	NSString *uuid = [NSUUID UUID].UUIDString;
	NSString *note = self.noteTextField.text;
	GeolocationFenceEventType eventType = self.eventTypeSegmentedControl.selectedSegmentIndex == 0 ? GeolocationFenceEventTypeEntry : GeolocationFenceEventTypeExit;
	
	[self.delegate configureFenceViewController:self didAddNewFenceAtCoordinate:coordinate withRadius:radius identifier:uuid notificationNote:note eventType:eventType];
}

- (IBAction)zoomToCurrentLocation:(id)sender {
	CLLocationCoordinate2D coordinate = self.mapView.userLocation.location.coordinate;
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 1000);
	[self.mapView setRegion:region animated:YES];
}

- (void)setToPresentDetailsForGeofence:(GeolocationFence *)fence
{
	_presentingDetails = YES;
	_existingFence = fence;
}

#pragma mark - <MKMapViewDelegate>

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	self.longitudeLabel.text = [NSString stringWithFormat:@"%.4f", self.mapView.centerCoordinate.longitude];
	self.latitudeLabel.text = [NSString stringWithFormat:@"%.4f", self.mapView.centerCoordinate.latitude];
}

@end
