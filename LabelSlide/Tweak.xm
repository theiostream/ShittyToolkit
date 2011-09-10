#import <UIKit/UIKit.h>

static NSMutableDictionary *plist;
static NSString *text;
static BOOL value;
static BOOL values;
static BOOL valued;
static BOOL valuet;

@interface SBAwayLockBar : NSObject {}
-(void)_setLabel:(id)label;
@end

static void loadPrefs() {
	if (!plist) plist = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.abart997.labelslide.plist"];
	text = (NSString *)[plist objectForKey:@"label"];
	value = [[plist objectForKey:@"enabled"] boolValue];
	values = [[plist objectForKey:@"customText"] boolValue];
	valued = [[plist objectForKey:@"thedate"] boolValue];
	valuet = [[plist objectForKey:@"thetime"] boolValue];
}

%hook SBAwayLockBar
NSTimer *timer = nil;
-(void)_setLabel:(id)label {

	if (!value) {
		%orig;
		return;
	}

	if (values) {
		if ([text isEqualToString:@""])
				label = @"Choose some text!";
			else
				label = text;
	}

	// only if there is no Custom Text enabled.
	else if(valuet||valued) {
		NSDateFormatter *dt = [[NSDateFormatter alloc] init];
		[dt setDateStyle:NSDateFormatterNoStyle];
		[dt setTimeStyle:NSDateFormatterShortStyle];
		if (valued) {
			[dt setDateFormat:@"dd-MM-YYYY"]; }
		else if (valuet) { // prefer date over time
			if (!timer) timer = [[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(run) userInfo:nil repeats:YES] retain];
		}
			
		NSString *date = [dt stringFromDate:[NSDate date]];
		label = date;
		[dt release];
	}
	// prefer date over time
	
	%orig;
}

- (void)dealloc {
	%orig;
	[timer invalidate];
}

%new(v@:)
- (void)run {
	NSDateFormatter *dateFor = [[NSDateFormatter alloc] init];
	[dateFor setDateStyle:NSDateFormatterNoStyle];
	[dateFor setTimeStyle:NSDateFormatterShortStyle];
	[dateFor setDateFormat:@"HH:MM:SS"];
	[self _setLabel:[dateFor stringFromDate:[NSDate date]]];
	[dateFor release];
}
%end

static void SettingsChanged() {
	if (text) { text = nil; }
	if (plist) { [plist release]; plist = nil; }
	loadPrefs();
}

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	%init;
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&SettingsChanged, CFSTR("com.abart997.labelslide.settingschangd"), NULL, CFNotificationSuspensionBehaviorHold);
	SettingsChanged();
	[pool release];
}
