#import <Preferences/Preferences.h>

@interface folderlockfreesettingsListController: PSListController <UIAlertViewDelegate> {
}
@end

@implementation folderlockfreesettingsListController

- (id)specifiers {
    if (_specifiers==nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"folderlockfreesettings" target:self] retain];
    }
    
    return _specifiers;
}

@end

// vim:ft=objc
