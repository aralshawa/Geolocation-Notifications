//
//  GeolocationFence.h
//  Geolocation Notifications
//
//  Created by Abdul Al-Shawa on 2016-07-16.
//  Copyright © 2016 Abdul Al-Shawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_OPTIONS(NSInteger, GeolocationFenceEventType) {
	GeolocationFenceEventTypeNone = 1 << 0,
	GeolocationFenceEventTypeEntry = 1 << 1,
	GeolocationFenceEventTypeExit = 1 << 2
};

@interface GeolocationFence : NSObject <NSCoding, MKAnnotation>

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) CLLocationDistance radius;
@property (nonatomic, strong) NSString *note;
@property (nonatomic) GeolocationFenceEventType eventType;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coord radius:(CLLocationDistance)rad identifier:(NSString *)uuid note:(NSString *)note eventType:(GeolocationFenceEventType)eventType;

@end
