//
//  NotificationTranscriptViewController.m
//  Geolocation Notifications
//
//  Created by Abdul Al-Shawa on 2016-07-24.
//  Copyright © 2016 Abdul Al-Shawa. All rights reserved.
//

#import "NotificationTranscriptViewController.h"
#import "GeolocationFence.h"

#define kEventLog @"kEventLog"
#define kLastSeenEvent @"kLastSeenEvent"

@implementation NotificationTranscriptViewController {
	NSInteger _lastSeenEntryIdx;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.logTextView.scrollEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.logTextView.contentInset = UIEdgeInsetsMake(5, 20, -5, -20);
	self.logTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
	
	NSAttributedString *logText = [self attributedStringForLog];
	
	if (logText.length > 0) {
		self.noEntriesLabel.hidden = YES;
		[self.logTextView setAttributedText:logText];
	} else {
		self.noEntriesLabel.hidden = NO;
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	self.logTextView.scrollEnabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	// Commit the index of the last entry seen
	[[NSUserDefaults standardUserDefaults] setInteger:_lastSeenEntryIdx forKey:kLastSeenEvent];
}

- (NSAttributedString *)attributedStringForLog
{
	NSMutableAttributedString *resultLog = [NSMutableAttributedString new];
	
	NSArray *archievedEvents = [[NSUserDefaults standardUserDefaults] arrayForKey:kEventLog];
	
	_lastSeenEntryIdx = [[NSUserDefaults standardUserDefaults] integerForKey:kLastSeenEvent];
	
	[archievedEvents enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSData * _Nonnull entryData, NSUInteger idx, BOOL * _Nonnull stop) {
		
		NSArray *entry = [NSKeyedUnarchiver unarchiveObjectWithData:entryData];
		NSDate *logDate = entry[0];
		GeolocationFence *fence = entry[1];
		
		NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
		[dateFormater setDateFormat:@"EEEE, MMM d, yyyy h:mm:ss a"];
		NSString *dateString = [dateFormater stringFromDate:logDate];
		
		NSString *fenceState = (fence.eventType & GeolocationFenceEventTypeEntry) ? @"Entered" : @"Left";
		NSString *fenceNote = fence.note;
		
		NSString *logEntry = [NSString stringWithFormat:@"%@ - %@\u2028\t%@\n", dateString, fenceState, fenceNote];
		
		NSMutableAttributedString *attributedLogEntry = [[NSMutableAttributedString alloc] initWithString:logEntry];
		
		UIFont *defaultFont = [UIFont systemFontOfSize:14];
		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
		paragraphStyle.paragraphSpacing = 0.5 * defaultFont.lineHeight;
		paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;

		// Common Attributes
		[attributedLogEntry addAttribute:NSFontAttributeName
								   value:defaultFont
								   range:NSMakeRange(0, logEntry.length)];
		[attributedLogEntry addAttribute:NSParagraphStyleAttributeName
								   value:paragraphStyle
								   range:NSMakeRange(0, logEntry.length)];
		
		// Date Attributes
		[attributedLogEntry addAttribute:NSFontAttributeName
								   value:[UIFont boldSystemFontOfSize:14]
								   range:NSMakeRange(0, dateString.length)];
		[attributedLogEntry addAttribute:NSForegroundColorAttributeName
								   value:[UIColor grayColor]
								   range:NSMakeRange(0, dateString.length)];
		
		// Event Type Attributes
		[attributedLogEntry addAttribute:NSForegroundColorAttributeName
								   value:[UIColor blueColor]
								   range:NSMakeRange(dateString.length + 3, fenceState.length)];
		
		if (idx > _lastSeenEntryIdx) {
			// Highlight all new entries
			[attributedLogEntry addAttribute:NSBackgroundColorAttributeName
									   value:[UIColor colorWithRed:1.00 green:1.00 blue:0.81 alpha:1.00]
									   range:NSMakeRange(0, dateString.length)];
		}
		
		[resultLog appendAttributedString:attributedLogEntry];
		
	}];
	
	// Update the last entry seen
	_lastSeenEntryIdx = archievedEvents.count - 1;
	
	return resultLog;
}

@end
