#import "Turann.h"
#define _POSIX_SPAWN_DISABLE_ASLR 0x0100
#define _POSIX_SPAWN_ALLOW_DATA_EXEC 0x2000
extern char **environ;

@implementation Turann
- (instancetype)init {
	self = [super init];
	if (self) {
		TurannAppearanceSettings *AppearanceSettings = [[TurannAppearanceSettings alloc] init];

		self.hb_appearanceSettings = AppearanceSettings;
		self.navigationItem.titleView = [UIView new];
		self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,10,10)];
		self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
		self.titleLabel.text = myTitle;
		//self.titleLabel.textColor = [UIColor greenColor];
		self.titleLabel.textAlignment = NSTextAlignmentCenter;
		[self.navigationItem.titleView addSubview:self.titleLabel];

		self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,10,10)];
		self.iconView.contentMode = UIViewContentModeScaleAspectFit;
		self.iconView.image = [UIImage imageNamed:myIcon inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
		self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
		self.iconView.alpha = 0.0;
		[self.navigationItem.titleView addSubview:self.iconView];

		[NSLayoutConstraint activateConstraints:@[
			[self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
			[self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
			[self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
			[self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
			[self.iconView.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
			[self.iconView.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
			[self.iconView.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
			[self.iconView.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
		]];
	}
	return self;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		self.chosenIDs = [[NSMutableArray alloc] init];
		_specifiers = [self loadSpecifiersFromPlistName:self.plistName target:self];

		for (PSSpecifier *specifier in _specifiers) {
			NSString *specifierID = [specifier propertyForKey:@"id"];
			if (specifierID)
				[self.chosenIDs addObject:specifierID];
		}

		self.savedSpecifiers = [NSMutableDictionary dictionary];
		for(PSSpecifier *specifier in _specifiers){
			if([self.chosenIDs containsObject:[specifier propertyForKey:@"id"]]){
				[self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
			}
		}
	}

	return _specifiers;
}

-(id)readPreferenceValue:(PSSpecifier *)specifier{
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)link:(NSString *)link name:(NSString *)name {
	name = [NSString stringWithFormat:@"Do you want to open %@?", name];
	UIAlertController *ask = [UIAlertController alertControllerWithTitle:@"PXL Battery"
	message:name preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:link] options:@{} completionHandler:nil];
	}];
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

	[ask addAction:confirmAction];
	[ask addAction:cancelAction];
	[[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ask animated:true completion:nil];
}

- (NSString *)RunCMD:(NSString *)RunCMD WaitUntilExit:(BOOL)WaitUntilExit {
	NSString *SSHGetFlex = [NSString stringWithFormat:@"%@",RunCMD];

	NSTask *task = [[NSTask alloc] init];
	NSMutableArray *args = [NSMutableArray array];
	[args addObject:@"-c"];
	[args addObject:SSHGetFlex];
	[task setLaunchPath:@"/bin/bash"];
	[task setArguments:args];
	if (WaitUntilExit) {
		NSPipe *outputPipe = [NSPipe pipe];
		[task setStandardInput:[NSPipe pipe]];
		[task setStandardOutput:outputPipe];
		[task launch];
		[task waitUntilExit];

		NSData *outputData = [[outputPipe fileHandleForReading] readDataToEndOfFile];
		NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
		return outputString;
	}
	[task launch];
	return nil;
}

-(NSString *) RunCMDWithLog:(NSString *)RunCMDWithLog {
	NSString *RunCC = [NSString stringWithFormat:@"%@",RunCMDWithLog];

	NSTask *task = [[NSTask alloc] init];
	NSMutableArray *args = [NSMutableArray array];
	[args addObject:@"-c"];
	[args addObject:RunCC];
	[task setLaunchPath:@"/bin/bash"];
	[task setArguments:args];
	NSPipe *outputPipe = [NSPipe pipe];
	[task setStandardInput:[NSPipe pipe]];
	[task setStandardOutput:outputPipe];
	[task launch];
	[task waitUntilExit];

	NSData *outputData = [[outputPipe fileHandleForReading] readDataToEndOfFile];
	NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];

	return outputString;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    [super setPreferenceValue:value specifier:specifier];

    if ([specifier.properties[@"id"] isEqualToString:@"swtch_custom_ticks"]) {
        BOOL customTicksActive = [value boolValue];

        PSSpecifier *batteryColorSpecifier = [self.savedSpecifiers objectForKey:@"battery_color"];
        PSSpecifier *tick1Specifier = [self.savedSpecifiers objectForKey:@"tick_1"];
        PSSpecifier *tick2Specifier = [self.savedSpecifiers objectForKey:@"tick_2"];
        PSSpecifier *tick3Specifier = [self.savedSpecifiers objectForKey:@"tick_3"];
        PSSpecifier *tick4Specifier = [self.savedSpecifiers objectForKey:@"tick_4"];
        PSSpecifier *tick5Specifier = [self.savedSpecifiers objectForKey:@"tick_5"];

        if (customTicksActive) {
            [_specifiers insertObject:tick1Specifier atIndex:[_specifiers indexOfObject:batteryColorSpecifier] + 1];
            [_specifiers insertObject:tick2Specifier atIndex:[_specifiers indexOfObject:batteryColorSpecifier] + 2];
            [_specifiers insertObject:tick3Specifier atIndex:[_specifiers indexOfObject:batteryColorSpecifier] + 3];
            [_specifiers insertObject:tick4Specifier atIndex:[_specifiers indexOfObject:batteryColorSpecifier] + 4];
            [_specifiers insertObject:tick5Specifier atIndex:[_specifiers indexOfObject:batteryColorSpecifier] + 5];
        } else {
            [_specifiers removeObject:tick1Specifier];
            [_specifiers removeObject:tick2Specifier];
            [_specifiers removeObject:tick3Specifier];
            [_specifiers removeObject:tick4Specifier];
            [_specifiers removeObject:tick5Specifier];
        }

        [self reloadSpecifiers];
    }

    CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
    if (notificationName) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	CGFloat offsetY = scrollView.contentOffset.y;

	if (offsetY > 1){
		[UIView animateWithDuration:0.7 animations:^{
			self.iconView.alpha = 1.0;
			self.titleLabel.alpha = 0.0;
		}];
	} else{
		[UIView animateWithDuration:0.7 animations:^{
			self.iconView.alpha = 0.0;
			self.titleLabel.alpha = 1.0;
		}];
	}

	if (offsetY > 0) offsetY = 0;
	self.headerImageView.frame = CGRectMake(0, offsetY, self.headerView.frame.size.width, 1 - offsetY);
}

-(void)reloadSpecifiers{
	[super reloadSpecifiers];
}

- (void)viewDidLoad{
	[super viewDidLoad];
	[self reloadSpecifiers];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	tableView.tableHeaderView = self.headerView;
	return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

-(void)Save{
	[self.view endEditing:YES];
}

- (void)_returnKeyPressed:(id)notification {
	[self Save];
}

@end
