// THIS IS A CLONE OF PAID SOFTWARE.
// THE AUTHOR CHOSE NOT TO REDISTRIBUTE THIS PACKAGE, EVEN IF THAT COULD BE DONE LEGALLY AS IT'S WRITTEN COMPLETELY BY HIM.
// YOU ARE NOT ALLOWED TO REDISTRIBUTE; AS FREE OR PAID PACKAGE IN ANY WAY.

// FolderLockFree (c) 2011 Matoe Productions LLC
// Special thanks to Maximus.

// TODO: Too lazy to use Apple's methods for inserting TextFields...
//       Do that; or use TIAlertView (http://github.com/theiostream/TIKit)

#import <UIKit/UIKit.h>

static NSMutableDictionary *dict = nil;
static BOOL shouldOpen = NO;

static BOOL isEnabled;
static NSString *passwd = nil;

static id karg;

@interface SBIconController : NSObject {}
- (void)openFolder:(id)folder animated:(BOOL)animated;
@end

static void loadPrefs() {
	NSLog(@"This is called!");
	if (!dict) dict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.yourcompany.folderlockfree-settings.plist"];
	isEnabled = [[dict objectForKey:@"Enabled"] boolValue];
	if (!passwd) passwd = (NSString *)[dict objectForKey:@"Password"];
}

%hook SBIconController
- (void)openFolder:(id)folder animated:(BOOL)animated {
	%log;
	karg = folder;
	
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"FolderLock" message:@"\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Go!", nil];
	av.tag = 1996;
	
	UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
	tf.tag = 2065;
	tf.clearButtonMode = UITextFieldViewModeAlways;
	tf.backgroundColor = [UIColor whiteColor];
	[tf becomeFirstResponder];
	
	[av addSubview:tf];
	
	if (isEnabled) {
		if (shouldOpen) {
			shouldOpen = NO;
			karg = nil;
			%orig;
		}
		else {
			[av show];
		}
	}
	else {
		%orig;
	}
	
	[av release];
	[tf release];
}

%new(v@:@i)
- (void)alertView:(UIAlertView *)alv clickedButtonAtIndex:(NSInteger)buttonIndex {
	%log;
	
	if ([alv tag]==1996) {
		if (buttonIndex==1) {
			UITextField *textField = nil;
			
			for (UIView *v in [alv subviews]) {
				if ([v tag]==2065) {
					textField = (UITextField *)v;
					break;
				}
			}
			
			if ([textField.text isEqualToString:passwd]) {
				shouldOpen = YES;
				[self openFolder:karg animated:YES]; // redo that fucking method
			}
		
			else {
				UIAlertView *av2 = [[UIAlertView alloc] initWithTitle:@"FolderLock" message:@"You typed the wrong password." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
				[av2 show];
				[av2 release];
			}
		}
	}
}

%end

static void SettingsChanged() {
	if (dict) { [dict release]; dict = nil; }
	if (passwd) passwd = nil;
	loadPrefs();
}

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	%init;
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&SettingsChanged, CFSTR("com.yourcompany.folderlockfree.settingschanged"), NULL,  CFNotificationSuspensionBehaviorHold);
	SettingsChanged();
	[pool drain];
}