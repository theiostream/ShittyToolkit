#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define TRASH_PATH @"/var/mobile/Library/RemovedApp/emptytrash.aif"

static BOOL value;
static BOOL values;
static BOOL valuet;
static NSMutableDictionary *plist = nil;

AVAudioPlayer *audioPlayer;

static void loadPrefs() {
	if (!plist) plist = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.abart997.removedapp.plist"];
	value = [[plist objectForKey:@"apps"]boolValue];
	values = [[plist objectForKey:@"mail"]boolValue];
	valuet = [[plist objectForKey:@"notes"]boolValue];
}

%hook SBDeleteIconAlertItem
-(void)alertView:(id)view clickedButtonAtIndex:(int)index{

	if(!value){
		return %orig;
	}
	
	else if (value){

		if(index == 0){
			%orig;
			NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:TRASH_PATH]];
        	audioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil] retain];
        	audioPlayer.numberOfLoops = 0;
			audioPlayer.volume = 1.0;
			[audioPlayer play];
		}
	}
}

- (void)dealloc {
	%orig;
	[audioPlayer release];
}
%end


%hook MailboxContentViewController
-(void)_reallyDeleteMessages:(id)messages{

	if(!values){
		return %orig;
	}
	else if (values){
		%orig;
		NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:TRASH_PATH]];
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        audioPlayer.numberOfLoops = 0;
		audioPlayer.volume = 1.0;
		[audioPlayer play];
	}
}

- (void)dealloc {
	%orig;
	[audioPlayer release];
}
%end

%hook NotesDisplayController

-(void)actionSheet:(id)sheet clickedButtonAtIndex:(int)index{

	if(!valuet){
		return %orig;
	}
	else if (valuet){
		if(index == 0){
			%orig;
			NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:TRASH_PATH]];
        	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        	audioPlayer.numberOfLoops = 0;
			audioPlayer.volume = 1.0;
			[audioPlayer play];
		}
	}
}	

- (void)dealloc {
	%orig;
	[audioPlayer release];
}
%end

static void SettingsChanged() {
	if (plist) { [plist release]; plist = nil; }
	loadPrefs();
}

%ctor {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	%init;
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&SettingsChanged, CFSTR("com.abart997.removedapp/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorHold);
	SettingsChanged();
	[p drain];
}
