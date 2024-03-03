#import "PXL_Preferences.h"

@implementation PXLPreferences {}

-(instancetype)init {
    myIcon = @"PXL";
	if (@available(iOS 15.0, *)) {
		self.BundlePath = @"/private/var/jb/var/Library/PreferenceBundles/PXL_Preferences.bundle";
	} else {
    	self.BundlePath = @"/Library/PreferenceBundles/PXL_Preferences.bundle";
	}
    self = [super init];
    return self;
}

-(NSArray *)specifiers {
	self.plistName = @"Root";
    return [super specifiers];
}


-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[UIView animateWithDuration:INFINITY animations:^{
		self.navigationController.navigationBar.tintColor = nil;
	}];
}

-(void)respringApply {
	_respringApplyButton = (_respringApplyButton) ? _respringApplyButton : [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(respringConfirm)];
	[[self navigationItem] setRightBarButtonItem:_respringApplyButton animated:YES];
}

-(void)respringConfirm {
	if ([[[self navigationItem] rightBarButtonItem] isEqual:_respringConfirmButton]) {
		[self respring];
	} else {
		_respringConfirmButton = (_respringConfirmButton) ? _respringConfirmButton : [[UIBarButtonItem alloc] initWithTitle:@"Respring?" style:UIBarButtonItemStylePlain target:self action:@selector(respringConfirm)];
		[_respringConfirmButton setTintColor:[UIColor colorWithRed:1.00 green:0.00 blue:0.00 alpha:1.00]];
		[[self navigationItem] setRightBarButtonItem:_respringConfirmButton animated:YES];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[self respringApply];
		});
	}
}

- (void)resetPrefs {
	UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithTitle:@"Restore Defaults?" style:UIBarButtonItemStylePlain target:self action:@selector(Confirm)];
	resetButton.tintColor = [UIColor redColor];
	self.navigationItem.rightBarButtonItem = resetButton;
}

- (void)Confirm {
	if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Are you sure?"]) {
		[self resetprefs];
		[self reloadSpecifiers];
		
		for (int i = 3; i > -1; i--) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((3-i) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"Respringing in %d", i];
			});
			
			if (i == 0) {
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					[self respring];
				});
			}
		}
	} else {
		self.navigationItem.rightBarButtonItem.title = @"Are you sure?";
		self.navigationItem.rightBarButtonItem.tintColor = [UIColor redColor];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{[self respringApply];});
	}
}

-(void)respring {
	NSTask *killallBackboardd = [NSTask new];
	[killallBackboardd setLaunchPath:@"/usr/bin/killall"];
	[killallBackboardd setArguments:@[@"-9", @"SpringBoard"]];
	[killallBackboardd launch];
}

-(void)resetprefs {
	NSTask *resetprefs = [NSTask new];
	[resetprefs setLaunchPath:@"/bin/rm"];
	[resetprefs setArguments:@[@"-f", @"/var/mobile/Library/Preferences/xyz.turannul.PXLBattery.plist"]];
	[resetprefs launch];
}

-(void)viewDidLoad {
	[super viewDidLoad];
	[self respringApply];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    /*
    Issues/Problems:
    1- @"BatteryColor" doesn't hide or show no matter what
    2- on showMe Ticks re-appears 5 to 1 which is weird.
    3- This changes only stays until reload
    */
    [super setPreferenceValue:value specifier:specifier];
    // NSString *key = [specifier propertyForKey:@"key"];
    BOOL singleColorMode = GetBool(@"SingleColorMode", YES);
    NSArray *keys_array = @[@"tick_1", @"tick_2", @"tick_3", @"tick_4", @"tick_5"];
    
    if (singleColorMode) { 
        // If SingleColorMode is on, hide BatteryColor and show tick1 to 5
        NSLog(@"PXL_Battery:reload:hideMe:keytohide:BatteryColor");
        [self hideMe:@"BatteryColor" animate:YES];
        // Show tick1 to 5 in forward order
        for (NSString *showKeys in keys_array) {
            NSLog(@"PXL_Battery:reload:showMe:showkeys:%@", showKeys);
            [self showMe:showKeys after:@"group_1" animate:YES];
        }
    } else { // If SingleColorMode is off, hide tick1 to 5 and show BatteryColor
        NSLog(@"PXL_Battery:reload:showMe:showkeys:BatteryColor");
        [self showMe:@"BatteryColor" after:@"group_1" animate:YES];
        // Hide tick1 to 5
        for (NSString *hideKeys in keys_array) {
            NSLog(@"PXL_Battery:reload:hideMe:keytohide:%@", hideKeys);
            [self hideMe:hideKeys animate:YES];
        }
    }
}


- (void)reloadSpecifiers {
    [super reloadSpecifiers];
}

// Buttons
-(void)SourceCode { [self link:@"https://github.com/turannul/PXL-Battery" name:@"Source Code"]; }
-(void)Twitter { [self link:@"https://twitter.com/ImNotTuran" name:@"Follow me?"]; }
-(void)DonateMe { [self link:@"https://cash.app/$TuranUl" name:@"Donate to me?"]; }
-(void)RandyTwitter { [self link:@"https://twitter.com/rj_skins?s=21&t=YudSBh0iDY9C5zQIsJbXcA" name:@"Follow Randy?"]; }
-(void)DonatetoRandy420 { [self link:@"https://www.paypal.com/paypalme/4Randy420" name:@"Donate to Randy?"]; }
@end