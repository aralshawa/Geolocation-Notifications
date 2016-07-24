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

@implementation NotificationTranscriptViewController

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

- (NSAttributedString *)attributedStringForLog
{
	NSMutableAttributedString *resultLog = [NSMutableAttributedString new];
	
	NSArray *archievedEvents = [[NSUserDefaults standardUserDefaults] arrayForKey:kEventLog];
	
	for (NSData *entryData in archievedEvents)
	{
		NSArray *entry = [NSKeyedUnarchiver unarchiveObjectWithData:entryData];
		NSDate *logDate = entry[0];
		GeolocationFence *fence = entry[1];
		
		NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
		[dateFormater setDateFormat:@"EEEE, MMM d, yyyy H:mm:ss a"];
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
		
		
		[resultLog appendAttributedString:attributedLogEntry];
	}
	
	return resultLog;
}

@end
