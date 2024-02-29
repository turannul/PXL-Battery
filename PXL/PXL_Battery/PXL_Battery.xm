#import "PXL_Battery.h"
#import "statics.h"

%group PXLBattery // Here go again
%hook UIStatusBar_Modern
-(long long)currentStyle {
    current_Style = %orig;
	// 3 = Light, 2 = null, 1 = unknown, 0 = Dark 
	StatusBarStyle = current_Style != 3;
	BatteryColor = StatusBarStyle ? [UIColor blackColor] : [UIColor whiteColor];
    // NSLog(@"PXL method: currentStyle:%lld", current_Style); 
	return %orig;}
%end

%hook _UIStaticBatteryView // Control Center Battery
-(bool) _showsInlineChargingIndicator { return PXLEnabled ? NO : %orig; }     // Hide charging bolt
-(bool) _shouldShowBolt { return PXLEnabled ? NO : %orig; }                   // Hide charging bolt x2
-(id) bodyColor { return PXLEnabled ? [UIColor clearColor] : %orig; }         // Hide the body
-(id) pinColor { return PXLEnabled ? [UIColor clearColor] : %orig; }          // Hide the pin
-(id) _batteryFillColor { return PXLEnabled ? [UIColor clearColor] : %orig; } // Hide the fill
-(void)_updateFillLayer { PXLEnabled ? [self Refresh_batteryIcon] : %orig; }  // Call Refresh_batteryIcon method
%end

%hook _UIBatteryView // SpringBoard Battery
%new
+ (instancetype)sharedInstance{
	static _UIBatteryView *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{ sharedInstance = (_UIBatteryView *) [[[self class] alloc] init]; });
	return sharedInstance;
}

-(bool) _showsInlineChargingIndicator { return PXLEnabled ? NO : %orig; }     // Hide charging bolt
-(bool) _shouldShowBolt { return PXLEnabled ? NO : %orig; }                   // Hide charging bolt x2
-(id) bodyColor { return PXLEnabled ? [UIColor clearColor] : %orig; }         // Hide the body
-(id) pinColor { return PXLEnabled ? [UIColor clearColor] : %orig; }          // Hide the pin
-(id) _batteryFillColor { return PXLEnabled ? [UIColor clearColor] : %orig; } // Hide the fill

//-----------------------------------------------
//Keep updating view
-(void)_updateFillLayer {
    if (!PXLEnabled) { %orig; return; }
    %orig; [self Refresh_batteryIcon];
}

// when low power mode activated
-(void)setSaverModeActive:(bool)arg1 {
    %orig;
    if (PXLEnabled) { [self Refresh_batteryIcon]; }
}

// when charger plugged
-(void)setChargingState:(long long)arg1 {
    %orig;
    isCharging = (arg1 == 1); // 1 = Charging
	if (PXLEnabled) { [self Refresh_batteryIcon]; }}

//-----------------------------------------------
//Update corresponding battery percentage
-(CGFloat)chargePercent {
    CGFloat origValue = %orig;
    BatteryLevel = origValue * 100;
    return origValue;
}

%new
-(void)cleanUpViews {
	for (UIImageView* imageView in [self subviews])
		[imageView removeFromSuperview];
}

%new
- (void)Refresh_batteryIcon {
    if (!PXLEnabled) return;

	[self chargePercent];
	batteryIcon = nil;
	batteryBar = nil;
	[self cleanUpViews];

	if (!batteryIcon) {
        batteryIcon = [[UIImageView alloc] initWithFrame:[self bounds]];
        [batteryIcon setContentMode:UIViewContentModeScaleAspectFill];
        [batteryIcon setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self addSubview:batteryIcon];
    }

    for (int i = sizeof(batteryBar_thresholds) / sizeof(batteryBar_thresholds[0]) - 1; i >= 0; i--) {
        if (BatteryLevel >= batteryBar_thresholds[i]) {
            batteryBar_Count = batteryBar_array[i];
            batteryBar_Percentage = (BatteryLevel - batteryBar_thresholds[i]) / (i == 0 ? 14.0f : 20.0f);
            break;
        }
    }

    float batteryBar_Width = (batteryIcon.frame.size.width - 6) / 6;
    float batteryBar_Height = batteryIcon.frame.size.height - 5;

	for (int i = 1; i <= batteryBar_Count; ++i){
		CGRect TicksFrame = CGRectMake(batteryFrameLocation_X + ((i-1)*(batteryBar_Width + 1)), batteryFrameLocation_Y, (i == batteryBar_Count) ? batteryBar_Width * batteryBar_Percentage : batteryBar_Width, batteryBar_Height);
		UIView *batteryBar = [[UIView alloc] initWithFrame:TicksFrame];
		[batteryBar setContentMode:UIViewContentModeScaleAspectFill];
		[batteryBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

		// While in low power mode
		if ([self saverModeActive]) { 
			batteryBar.backgroundColor = LowPowerModeColor;
		// While charging
		} else if (isCharging) { 
			batteryBar.backgroundColor = ChargingColor;
		// While SingleColorMode is on
		} else if (SingleColorMode) { 
			batteryBar.backgroundColor = (BatteryLevel <= 20) ? LowBatteryColor : BatteryColor;
		// While SingleColorMode is off
		} else {
			switch (i) {
				case 1:
					batteryBar.backgroundColor = (BatteryLevel >= 0) ? Bar1 : nil;
					break;
				case 2:
					batteryBar.backgroundColor = (BatteryLevel >= 20) ? Bar2 : nil;
					break;
				case 3:
					batteryBar.backgroundColor = (BatteryLevel >= 40) ? Bar3 : nil;
					break;
				case 4:
					batteryBar.backgroundColor = (BatteryLevel >= 60) ? Bar4 : nil;
					break;
				case 5:
					batteryBar.backgroundColor = (BatteryLevel >= 80) ? Bar5 : nil;
					break;
			}
		}
		[self addSubview:batteryBar];
	}

	[batteryIcon setImage:[UIImage imageWithData:batteryFrame_img]];
	[self Refresh_batteryIcon_Color];
}

%new
// Load colors in conditions
- (void)Refresh_batteryIcon_Color {
    if (!PXLEnabled) return;
    batteryIcon.image = [batteryIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    batteryBar.image = [batteryBar.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if ([self saverModeActive]) {
        batteryIcon_TintColor = batteryBar_TintColor = LowPowerModeColor;
    } else if (isCharging) {
        batteryIcon_TintColor = batteryBar_TintColor = ChargingColor;
    } else {
        if (BatteryLevel >= 20) {
            batteryIcon_TintColor = batteryBar_TintColor = BatteryColor;
        } else if (BatteryLevel >= 10) {
            batteryIcon_TintColor = batteryBar_TintColor = BatteryColor;
        } else {
            batteryIcon_TintColor = LowBatteryColor;
            batteryBar_TintColor = batteryBar.backgroundColor = LowBatteryColor;
        }
    }
    [batteryIcon setTintColor:batteryIcon_TintColor];
    [batteryBar setTintColor:batteryBar_TintColor];
}
%end
%end

%ctor{
	loader();
	%init(PXLBattery);
}
