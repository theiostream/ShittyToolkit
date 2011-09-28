#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static UIButton *btn;
static UIButton *button;

UIImage *photo = [UIImage imageWithData:[NSData dataWithContentsOfFile:@"/var/mobile/Library/SBVolume/high.png"]];
UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:@"/var/mobile/Library/SBVolume/low.png"]];

@interface VolumeControl : NSObject { }
-(void)increaseVolume;
-(void)decreaseVolume;
-(void)cancelVolumeEvent;
+(id)sharedVolumeControl;
@end

%hook SBUIController
-(void)finishLaunching {
	%orig; // @abart997 missed this -.-
	
	btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.frame = CGRectMake(20.0, 375.0, 40.0, 20.0);
	// [btn setTitle:@"-" forState:UIControlStateNormal];
	// [btn setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
	[btn setBackgroundImage:image forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(decrease)forControlEvents:UIControlEventTouchUpInside];
	[[self window] addSubview:btn];

	button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(270.0, 375.0, 40.0, 20.0);
	// [button setTitle:@"+" forState:UIControlStateNormal];
	// [button setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
	[button setBackgroundImage:photo forState:UIControlStateNormal];
	[button addTarget:self action:@selector(increase)forControlEvents:UIControlEventTouchUpInside];
	[[self window] addSubview:button];
}

- (void)dealloc {
	%orig;
	[button release];
	[btn release];
}

%new
-(void)decrease {
	[[objc_getClass("VolumeControl") sharedVolumeControl] decreaseVolume];
	[[objc_getClass("VolumeControl") sharedVolumeControl] cancelVolumeEvent];
}
		
		
%new
-(void)increase {
	[[objc_getClass("VolumeControl") sharedVolumeControl] increaseVolume];
	[[objc_getClass("VolumeControl") sharedVolumeControl] cancelVolumeEvent];
}

%end