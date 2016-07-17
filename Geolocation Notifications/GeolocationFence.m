//
//  GeolocationFence.m
//  Geolocation Notifications
//
//  Created by Abdul Al-Shawa on 2016-07-16.
//  Copyright © 2016 Abdul Al-Shawa. All rights reserved.
//

#import "GeolocationFence.h"

@implementation GeolocationFence

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coord radius:(CLLocationDistance)rad identifier:(NSString *)uuid note:(NSString *)note eventType:(GeolocationFenceEventType)eventType
{
	if (self = [super init]) {
		_coordinate = coord;
		_radius = rad;
		_uuid = [uuid copy];
		_note = [note copy];
		_eventType = eventType;
	}
	
	return self;
}

- (NSString *)title {
	if (self.note.length > 0) {
		return self.note;
	}
	
	return [@"Region " stringByAppendingString:self.uuid];
}

- (NSString *)subtitle {
	NSString *eventStr = self.eventType == GeolocationFenceEventTypeEntry ? @"On Entry" : @"On Exit";
	return [NSString stringWithFormat:@"Radius %.2f m   %@", self.radius, eventStr];
}

#pragma mark - <NSCoding>

#define kLatitudeKey @"kLatitudeKey"
#define kLongitudeKey @"kLongitudeKey"
#define kRadiusKey @"kRadiusKey"
#define kUUIDKey @"kUUIDKey"
#define kNoteKey @"kNoteKey"
#define kEventTypeKey @"kEventTypeKey"

- (instancetype)initWithCoder:(NSCoder *)decoder
{
	CLLocationDegrees latitude = [decoder decodeDoubleForKey:kLatitudeKey];
	CLLocationDegrees longitude = [decoder decodeDoubleForKey:kLongitudeKey];
	CLLocationDistance radius = [decoder decodeDoubleForKey:kRadiusKey];
	NSString *uuid = [decoder decodeObjectForKey:kUUIDKey];
	NSString *note = [decoder decodeObjectForKey:kNoteKey];
	GeolocationFenceEventType event = [decoder decodeIntegerForKey:kEventTypeKey];
	
	return [self initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) radius:radius identifier:uuid note:note eventType:event];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeDouble:self.coordinate.latitude forKey:kLatitudeKey];
	[encoder encodeDouble:self.coordinate.longitude forKey:kLongitudeKey];
	[encoder encodeDouble:self.radius forKey:kRadiusKey];
	[encoder encodeObject:self.uuid forKey:kUUIDKey];
	[encoder encodeObject:self.note forKey:kNoteKey];
	[encoder encodeInteger:self.eventType forKey:kEventTypeKey];
}

@end
