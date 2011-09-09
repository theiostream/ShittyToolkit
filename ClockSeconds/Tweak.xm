/*
Code by abart997
Working better thanks to theiostream (prefs + nonstop timer)
This code is freaking /ugly/ because even if you disable seconds, that timer will keep running/repeating.
Still, it shouldn't get so much of your memory as it is only executed while on the LockScreen
*/

#import <UIKit/UIKit.h>
#import <objc/runtime.h>


@interface TPLCDTextView : UIView { }
-(void)setText:(id)text;
-(void)setTextColor:(id)color;
-(id)grabPrefColor:(NSInteger)colorNumber;
@end

static NSInteger clockColor;

%hook SBAwayDateView
- (id)initWithFrame:(CGRect)frame {
	if ((self = %orig)) {
		NSTimer *dateTimer = MSHookIvar<NSTimer *>(self, "_dateTimer");
		id userInfo = [[dateTimer userInfo] copy];
		[dateTimer invalidate];
		[dateTimer release];
		dateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateClock) userInfo:userInfo repeats:YES];
	}
	return self;
}

-(void)updateClock{
	NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.abart997.clockseconds.plist"];
	clockColor = [[(NSNumber*)plist valueForKey:@"clockColor"] integerValue];

	%orig;
	
	TPLCDTextView *time = MSHookIvar<TPLCDTextView *>(self, "_timeLabel");
	
	NSDateFormatter *dt = [[NSDateFormatter alloc] init];
	[dt setDateStyle:NSDateFormatterNoStyle];
	[dt setTimeStyle:NSDateFormatterShortStyle];
	[dt setDateFormat:@"HH:mm:ss"];
	
	![[plist objectForKey:@"SecondsEnabled"] boolValue] ? NSLog(@"Bozo!") : [time setText:[dt stringFromDate:[NSDate date]]];
	![[plist objectForKey:@"ColorEnabled"] boolValue] ? NSLog(@"Again, Bozo!") : [time setTextColor: [self grabPrefColor:clockColor]];

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
