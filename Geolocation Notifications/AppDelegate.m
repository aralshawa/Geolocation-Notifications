//
//  AppDelegate.m
//  Geolocation Notifications
//
//  Created by Abdul Al-Shawa on 2016-07-16.
//  Copyright © 2016 Abdul Al-Shawa. All rights reserved.
//

#import "AppDelegate.h"
#import "GeolocationFence.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Location Manager Initialization
	self.locationManager = [CLLocationManager new];
	self.locationManager.delegate = self;
	[self.locationManager requestAlwaysAuthorization];
	
	// Notications Initialization & Cleanup
	[application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Location Management
#define kGeofenceListKey @"kGeofenceListKey"
#define kEventLog @"kEventLog"

- (void)handleRegionEvent:(CLRegion *)region
{
	GeolocationFence *fenceTriggered = [self fenceForCLRegionIdentifer:region.identifier];
	NSString *msg = fenceTriggered.note;
	
	if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
		// Present modal notification if the application is active
		if (msg != nil) {
			UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"Yay!" style:UIAlertActionStyleCancel handler:NULL];
			
			[alertController addAction:alertAction];
			
			[_window.rootViewController presentViewController:alertController animated:YES completion:NULL];
		}
	} else {
		// Trigger a local notification is the application is inactive or in the background
		UILocalNotification *localNotification = [UILocalNotification new];
		localNotification.alertBody = msg;
		localNotification.soundName = UILocalNotificationDefaultSoundName;
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
	}
	
	[self recordGeolocationEventForFence:fenceTriggered];
}

- (GeolocationFence *)fenceForCLRegionIdentifer:(NSString *)iden
{
	NSArray *archievedFences = [[NSUserDefaults standardUserDefaults] arrayForKey:kGeofenceListKey];
	
	for (NSData *savedItem in archievedFences) {
		GeolocationFence *fence = [NSKeyedUnarchiver unarchiveObjectWithData:savedItem];
		if ([fence.uuid isEqualToString:iden]) {
			return fence;
		}
	}
	
	return nil;
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
	if ([region isKindOfClass:[CLCircularRegion class]]) {
		[self handleRegionEvent:region];
	}
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
	if ([region isKindOfClass:[CLCircularRegion class]]) {
		[self handleRegionEvent:region];
	}
}

- (void)recordGeolocationEventForFence:(GeolocationFence *)fence
{
	NSMutableArray *itemsToArchieve = [[[NSUserDefaults standardUserDefaults] arrayForKey:kEventLog] mutableCopy];
	
	if (itemsToArchieve == nil) {
		itemsToArchieve = [NSMutableArray array];
	}
	
	NSArray *eventEntry = @[[NSDate date], fence];
	[itemsToArchieve addObject:[NSKeyedArchiver archivedDataWithRootObject:eventEntry]];
	
	[[NSUserDefaults standardUserDefaults] setObject:itemsToArchieve forKey:kEventLog];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
