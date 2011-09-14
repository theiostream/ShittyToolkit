/*
Code by abart997
Working better thanks to theiostream (prefs + nonstop timer)
Ugly, but works. (also less ugly than my first version was) -- check commit history
Still, it shouldn't get so much of your memory as it is only executed while on the LockScreen (maybe...?)
*/

// TODO: fix mem leaks on dateTimer (it will keep runnin and runnin)
// Do CFNotificationCenterAddObserver()

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static NSMutableDictionary *plist = nil;
static NSDateFormatter *dt = nil;
static BOOL mustReleaseFormatter = NO;

@interface TPLCDTextView : UIView { }
-(void)setText:(id)text;
-(void)setTextColor:(id)color;
-(id)grabPrefColor:(NSInteger)colorNumber;
@end

static NSInteger clockColor;

%hook SBAwayDateView
- (id)initWithFrame:(CGRect)frame {
	if ((self = %orig)) {
		if (!plist)
			plist = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.abart997.clockseconds.plist"];
		
		if ([[plist objectForKey:@"SecondsEnabled"] boolValue]||[[plist objectForKey:@"ColorEnabled"] boolValue]) {
			mustReleaseFormatter = YES;
			NSTimer *dateTimer = MSHookIvar<NSTimer *>(self, "_dateTimer");
			id userInfo = [[[dateTimer userInfo] copy] autorelease];
			[dateTimer invalidate];
			[dateTimer release];
			dateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateClock) userInfo:userInfo repeats:YES];
		}
	}
	return self;
}

-(void)updateClock{
	clockColor = [[(NSNumber*)plist valueForKey:@"clockColor"] integerValue];

	%orig;
	
	TPLCDTextView *time = MSHookIvar<TPLCDTextView *>(self, "_timeLabel");
	
	if (dt==nil) {
		dt = [[NSDateFormatter alloc] init];
	}
	[dt setDateStyle:NSDateFormatterNoStyle];
	[dt setTimeStyle:NSDateFormatterShortStyle];
	[dt setDateFormat:@"HH:mm:ss"];
	
	if ([[plist objectForKey:@"SecondsEnabled"] boolValue]) [time setText:[dt stringFromDate:[NSDate date]]];
	if ([[plist objectForKey:@"ColorEnabled"] boolValue]) [time setTextColor: [self grabPrefColor:clockColor]];
	// took away syslog flood.
}

- (void)dealloc {
	NSLog(@"================= [ClockSeconds] Called -[SBAwayDateView dealloc]");
	
	%orig;
	[plist release];
	if (mustReleaseFormatter) { [dt release]; mustReleaseFormatter = NO; }
}

%new(v@:i)
-(id)grabPrefColor:(NSInteger)colorNumber {
		switch (colorNumber) {
		
			case 0:
				return [UIColor redColor]; break;
			case 1:
				return [UIColor blueColor]; break;
			case 2:
				return [UIColor greenColor]; break;
			case 3:
				return [UIColor blackColor]; break;
			case 4:
				return [UIColor brownColor]; break;
			case 5:
				return [UIColor purpleColor]; break;
			case 6:
				return [UIColor whiteColor]; break;
			case 7:
				return [UIColor orangeColor]; break;
			default:
				return [UIColor redColor];
	}

}

%end
