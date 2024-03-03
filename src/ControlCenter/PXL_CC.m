#import "PXL_CC.h"

#define SETTINGS_CHANGED "xyz.turannul.PXLBattery.settingschanged"
#define PREFS CFSTR("xyz.turannul.PXLBattery")
#define PLIST @"/var/mobile/Library/Preferences/xyz.turannul.PXLBattery.plist"

@implementation PXL_Switch 
static BOOL GetBool(NSString *key, BOOL defaultValue) {
	Boolean exists;
	Boolean result = CFPreferencesGetAppBooleanValue((CFStringRef)key, CFSTR("xyz.turannul.PXLBattery"), &exists);
	return exists ? result : defaultValue;
}

- (UIImage *)iconGlyph {
	return [UIImage imageNamed:@"Icon" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

- (UIColor *)selectedColor {
	return [UIColor colorWithRed:(0.0/255.0) green:(0.0/255.0) blue:(0.0/255.0) alpha:1.0];
}

- (bool)isSelected {
	return GetBool(@"pxlEnabled", NO);
}

- (void)setSelected:(bool)selected {
	[super refreshState];
	NSMutableDictionary *Dict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:PLIST]];
	[Dict setValue:[NSNumber numberWithBool:selected] forKey:@"pxlEnabled"];
	[Dict writeToFile:PLIST atomically:YES];
	CFPreferencesSetAppValue((CFStringRef)@"pxlEnabled", (CFPropertyListRef)@(selected), PREFS);
	CFPreferencesAppSynchronize(PREFS);
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(SETTINGS_CHANGED), NULL, NULL, TRUE);
}
@end
