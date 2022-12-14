#import "PXLDebug.h"

@implementation PXLDebug

-(instancetype)init
{
    myIcon = @"PXL";
    myTitle = @"Debug options";
    self.BundlePath=@"/Library/PreferenceBundles/PXL.bundle";



    self = [super init];
    return self;
}

-(NSArray *)specifiers
{
    self.plistName = @"DebugPrefs";
    self.chosenIDs = @[@"example1", @"example2"];
    return [super specifiers];
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier
{
    [super setPreferenceValue:value specifier:specifier];
}

-(void)reloadSpecifiers{[super reloadSpecifiers];}

-(void)putBool:(BOOL)putBool forKey:(NSString *)key
{
    NSMutableDictionary *preferences;
    preferences = [[NSMutableDictionary alloc] init];

    [preferences setObject:[NSNumber numberWithBool:putBool] forKey:key];
    [preferences writeToFile:@"/var/mobile/Library/Preferences/xyz.turannul.pxlbattery.plist" atomically:YES];
    [self reloadSpecifiers];
}
/*
Debug prefs works without respring
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:INFINITY animations:^{
        [[[[self navigationController] navigationController] navigationBar] setTintColor:nil];
    }];
}

-(void)respringApply
{
    _respringApplyButton = (_respringApplyButton)? _respringApplyButton : [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(respringConfirm)];
    [[self navigationItem] setRightBarButtonItem:_respringApplyButton animated:YES];
}

-(void)respringConfirm
{
    if ([[[self navigationItem] rightBarButtonItem] isEqual:_respringConfirmButton]){
        [self respring];
    }else{
        _respringConfirmButton = (_respringConfirmButton)? _respringConfirmButton : [[UIBarButtonItem alloc] initWithTitle:@"Respring?" style:UIBarButtonItemStylePlain target:self action:@selector(respringConfirm)];
        [_respringConfirmButton setTintColor:[UIColor colorWithRed: 1.00 green: 0.00 blue: 0.00 alpha: 1.00]];
        [[self navigationItem] setRightBarButtonItem:_respringConfirmButton animated:YES];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self respringApply];
        });
    }
}

-(void)respring
{
    NSTask *killallBackboardd = [NSTask new];
    [killallBackboardd setLaunchPath:@"/usr/bin/killall"];
    [killallBackboardd setArguments:@[@"-9", @"backboardd"]];
    [killallBackboardd launch];
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self respringApply];
}
*/
@end
