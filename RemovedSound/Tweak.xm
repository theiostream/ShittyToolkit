#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#include <AudioToolbox/AudioToolbox.h>

#define TRASH_PATH @"/var/mobile/Library/RemovedApp/emptytrash.aif"

static BOOL value;
static BOOL values;
static BOOL valuet;
static NSMutableDictionary *plist = nil;

SystemSoundID sound;

static void loadPrefs() {
	if (!plist) plist = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.abart997.removedapp.plist"];
	value = [[plist objectForKey:@"apps"]boolValue];
	values = [[plist objectForKey:@"mail"]boolValue];
	valuet = [[plist objectForKey:@"notes"]boolValue];
}

%hook SBDeleteIconAlertItem
-(void)alertView:(id)view clickedButtonAtIndex:(int)index{
	%orig;
	if (value)
		if (index == 0)
			AudioServicesPlaySystemSound(sound);
}
%end


%hook MailboxContentViewController
-(void)_reallyDeleteMessages:(id)messages{
	%orig;
	if (values) AudioServicesPlaySystemSound(sound);
}
%end

%hook NotesDisplayController

-(void)actionSheet:(id)sheet clickedButtonAtIndex:(int)index{
	%orig;
	
	if (valuet)
		if (index == 0)
			AudioServicesPlaySystemSound(sound);
}
%end

static void SettingsChanged() {
	if (plist) { [plist release]; plist = nil; }
	loadPrefs();
}

%ctor {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	%init;
	
	// setup prefs
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&SettingsChanged, CFSTR("com.abart997.removedapp/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorHold);
	SettingsChanged();
	
	// setup audioplayer
	NSURL *filePath = [NSURL fileURLWithPath:TRASH_PATH isDirectory:NO];
	AudioServicesCreateSystemSoundID((CFURLRef)filePath, &sound);
	
	
	[p drain];
}
