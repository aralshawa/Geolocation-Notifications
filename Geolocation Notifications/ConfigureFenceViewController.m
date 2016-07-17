//
//  ConfigureFenceViewController.m
//  Geolocation Notifications
//
//  Created by Abdul Al-Shawa on 2016-07-16.
//  Copyright © 2016 Abdul Al-Shawa. All rights reserved.
//

#import "ConfigureFenceViewController.h"

@interface ConfigureFenceViewController ()

@end

@implementation ConfigureFenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.rightBarButtonItems = @[self.addBtn, self.currLocationBtn];
	self.addBtn.enabled = NO;
	
	self.tableView.tableFooterView = [UIView new];
	
	if ([self.delegate respondsToSelector:@selector(initialRegionToBeginFenceSelection)]) {
		[self.mapView setRegion:[self.delegate initialRegionToBeginFenceSelection]];
	}
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

@end
