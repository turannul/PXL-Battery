#pragma GCC diagnostic ignored "-Wunused-function"
#include <Preferences/PSListController.h>
#include <Preferences/PSSpecifier.h>
#include <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import "colors.h"
#import "NSTask.h"

@interface PSListController (iOS12Plus)
-(BOOL)containsSpecifier:(PSSpecifier *)arg1;
@end

@interface TurannAppearanceSettings : HBAppearanceSettings
@end

@interface Turann : HBListController
{
	NSFileManager *fm;
	NSString *myIcon;
	NSString *myTitle;
	UITableView *_table;
}
@property (nonatomic, strong) NSMutableArray *chosenIDs;
@property (nonatomic, strong) NSString *plistName;
@property (nonatomic, strong) NSString *BundlePath;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UIImageView *headerImageView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *credit;
@property (nonatomic, retain) UIImageView *iconView;
@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;

-(void)link:(NSString *)link name:(NSString *)name;
-(NSString *)RunCMD:(NSString *)RunCMD WaitUntilExit:(BOOL)WaitUntilExit;
-(NSString *)RunCMDWithLog:(NSString *)RunCMDWithLog;
-(void)Save;
@end

static id CC(NSString *CMD) {
	return [NSString stringWithFormat:@"echo \"%@\" | gap",CMD];
}

@interface NSTask (NSTaskConveniences)
+(NSTask *)launchedTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments;
// convenience; create and launch
-(void)waitUntilExit;
// poll the runLoop in defaultMode until task completes
@end

FOUNDATION_EXPORT NSString * const NSTaskDidTerminateNotification;

static NSString *GetNSString(NSString *pkey, NSString *defaultValue, NSString *plst){
	NSDictionary *Dict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist",plst]];

	return [Dict objectForKey:pkey] ? [Dict objectForKey:pkey] : defaultValue;
}

static BOOL GetBool(NSString *pkey, BOOL defaultValue, NSString *plst) {
	NSDictionary *Dict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist",plst]];

	return [Dict objectForKey:pkey] ? [[Dict objectForKey:pkey] boolValue] : defaultValue;
}

#define buttonCell(name) [PSSpecifier preferenceSpecifierNamed:name target:self set:NULL get:NULL detail:NULL cell:PSButtonCell edit:Nil]
#define groupSpec(name) [PSSpecifier groupSpecifierWithName:name]
#define sliderCell(name) [PSSpecifier preferenceSpecifierNamed: name target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NULL cell:PSSliderCell edit:Nil]
#define subtitleSwitchCell(name) [PSSpecifier preferenceSpecifierNamed:name target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NULL cell:PSSwitchCell edit:Nil]
#define switchCell(name) [PSSpecifier preferenceSpecifierNamed:name target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NULL cell:PSSwitchCell edit:Nil]
#define textCell(name) [PSSpecifier preferenceSpecifierNamed:name target:self set:NULL get:NULL detail:NULL cell:PSStaticTextCell edit:Nil]
#define linkCell(name, controller) [PSSpecifier preferenceSpecifierNamed:name target:self set:NULL get:NULL detail:NSClassFromString(controller) cell:PSLinkCell edit:Nil]
#define setClass(className) [specifier setProperty:className forKey:@"cellClass"]
#define setAction(action) [specifier setProperty:action forKey:@"action"]
#define setDefaultForSpec(sDefault) [specifier setProperty:sDefault forKey:@"default"]
#define setKey(key) [specifier setProperty:key forKey:@"key"]
#define setId(id) [specifier setProperty:id forKey:@"id"]
#define setAlign(align) [specifier setProperty:align forKey:@"alignment"]
#define setImg(img) [specifier setProperty:[self imageNamed:img] forKey:@"iconImage"]
#define setFooter(footer) [specifier setProperty:footer forKey:@"footerText"]
#define setMin(minimum) [specifier setProperty:minimum forKey:@"min"]
#define setMax(maximum) [specifier setProperty:maximum forKey:@"max"]
#define setShowsValue(shows) [specifier setProperty:shows forKey:@"showValue"]
#define addSpec [mutableSpecifiers addObject:specifier]