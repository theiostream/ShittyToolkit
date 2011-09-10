/*
Code by abart997
Working better thanks to theiostream (prefs + nonstop timer)
Ugly, but works. (also less ugly than my first version was) -- check commit history
Still, it shouldn't get so much of your memory as it is only executed while on the LockScreen
*/

// TODO: fix mem leaks on dateTimer and userInfo
// although it shouldn't get so much mem as it's lockscreen only. it also deallocs most stuff.
// message me your contributions, and also any other mem leak that you find.

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static NSMutableDictionary *plist = nil;
static NSDateFormatter *dt = nil;

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
		
		if ([[plist objectForKey:@"SecondsEnabled"] boolValue]) {
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
	
	if (![[plist objectForKey:@"SecondsEnabled"] boolValue])
		return;
	
	TPLCDTextView *time = MSHookIvar<TPLCDTextView *>(self, "_timeLabel");
	
	if (dt==nil) {
		dt = [[NSDateFormatter alloc] init];
	}
	[dt setDateStyle:NSDateFormatterNoStyle];
	[dt setTimeStyle:NSDateFormatterShortStyle];
	[dt setDateFormat:@"HH:mm:ss"];
	
	![[plist objectForKey:@"SecondsEnabled"] boolValue] ? NSLog(@"test") : [time setText:[dt stringFromDate:[NSDate date]]];
	![[plist objectForKey:@"ColorEnabled"] boolValue] ? NSLog(@"test") : [time setTextColor: [self grabPrefColor:clockColor]];
}

- (void)dealloc {
	%orig;
	[plist release];
	[dt release];
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
