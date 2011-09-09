// ShittyRespring -- by abart997 + theiostream
// "Making shit less shit doesn't mean it has stopped being shit."

// Thanks to iHeli0s and SBBrightness source, for reminding me where to put stuff and save me from a dump search.
// has a bug with FolderEnhancer... Although I doubt anyone will be using this tweak so... Who cares? :D
// also rotation on the iPad?... Works in a shitty way (my fault, was too lazy and saw no need to make that amazing)

#import <UIKit/UIKit.h>
static UIButton *btn;
static BOOL itsok = YES;

@interface UIDevice (theiostream)
- (BOOL)isWildcat;
@end

@interface SBUIController : NSObject {}
- (void)setFrameForButton:(UIButton *)ok;
- (id)window;
@end

%hook SBUIController
-(void)finishLaunching{
	%orig;
	
	btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self setFrameForButton:btn];
	
	[btn setTitle:@"Respring" forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
	
	[btn addTarget:self action:@selector(changeName:) forControlEvents:UIControlEventTouchDown];
	[btn addTarget:self action:@selector(respring) forControlEvents:UIControlEventTouchUpInside];
	[[self window] addSubview:btn];
}

- (void)window:(id)window willRotateToInterfaceOrientation:(int)orientation duration:(double)duration {
	%orig;
	if (orientation==2&&[[UIDevice currentDevice] isWildcat]) {
		btn.frame = CGRectMake(244, 184, 280, 20);
		return;
	}
	[self setFrameForButton:btn];
}

- (void)dealloc {
	%orig;
	[btn release];
}

%new(v@:)
- (void)setFrameForButton:(UIButton *)ok {
	if ([[UIDevice currentDevice] isWildcat]) {
		if([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
			ok.frame = CGRectMake(244, 840, 280, 20);
		}
		else {
			ok.frame = CGRectMake(244, 25, 280, 20);
		}
	}
	else {
		ok.frame = CGRectMake(15.0, 375.0 ,280.0, 20.0); // I give rotating up.
	}
}

%new(v@:@@)
- (void)changeName:(id)button {
	[button setTitle:@"Done..." forState:UIControlStateNormal];
	itsok = NO;
}

%new(v@:)
-(void)respring {
	itsok = YES;
	system("killall -9 SpringBoard"); // this is just fine.
}

%end

%hook SBIconController
- (void)openFolder:(id)folder animated:(BOOL)animated {
	[btn setHidden:YES];
	%orig;
}

// doesn't work for FolderEnhancer 0_o
- (void)closeFolderAnimated:(BOOL)animated {
	[btn setHidden:NO];
	%orig;
}
%end

%hook SBAppSwitcherController
-(void)viewWillAppear {
	[btn setHidden:YES];
	%orig;
}

-(void)appSwitcherBarRemovedFromSuperview:(id)superview {
	%orig;
	[btn setHidden:NO];
}
%end

%hook SBSearchController
-(void)searchBarTextDidBeginEditing:(id)searchBarText {
	[btn setHidden:YES];
	%orig;
}

-(void)searchBarTextDidEndEditing:(id)searchBarText {
	%orig;
	[btn setHidden:NO];
}
%end