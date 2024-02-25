#import "PXL_Battery.h"
#import "statics.h"

%group PXLBattery // Here go again
%hook UIStatusBar_Modern
-(NSInteger)_effectiveStyleFromStyle:(NSInteger)arg1 {
    statusBarDark = (arg1 != 1); // 1 = Dark, 0 = Light.
    BatteryColor = statusBarDark ? [UIColor blackColor] : [UIColor whiteColor];
	//NSLog(@"Is the statusBarDark: %d", statusBarDark);
	return %orig;  // We don't want to interrupt how system works we adapting to it.
}
%end


%hook _UIStaticBatteryView // Control Center Battery
-(bool) _showsInlineChargingIndicator { return PXLEnabled ? NO : %orig; }     // Hide charging bolt
-(bool) _shouldShowBolt { return PXLEnabled ? NO : %orig; }                   // Hide charging bolt x2
-(id) bodyColor { return PXLEnabled ? [UIColor clearColor] : %orig; }         // Hide the body
-(id) pinColor { return PXLEnabled ? [UIColor clearColor] : %orig; }          // Hide the pin
-(id) _batteryFillColor { return PXLEnabled ? [UIColor clearColor] : %orig; } // Hide the fill
-(void)_updateFillLayer { PXLEnabled ? [self refreshIcon] : %orig; }          // Call refreshIcon method
%end

%hook _UIBatteryView // SpringBoard Battery
%new
+ (instancetype)sharedInstance{
	static _UIBatteryView *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = (_UIBatteryView *) [[[self class] alloc] init];
	});
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
    %orig; [self refreshIcon];
}


// when low power mode activated
-(void)setSaverModeActive:(bool)arg1 {
    %orig;
    if (PXLEnabled) { [self refreshIcon]; }
}

// when charger plugged
-(void)setChargingState:(long long)arg1 {
    %orig;
    isCharging = (arg1 == 1); // 1 = Charging
	if (PXLEnabled) { [self refreshIcon]; }}

//-----------------------------------------------
//Update corresponding battery percentage
-(CGFloat)chargePercent {
    CGFloat origValue = %orig;
    actualPercentage = origValue * 100;
    return origValue;
}

%new
-(void)cleanUpViews{
	for (UIImageView* imageView in [self subviews])
		[imageView removeFromSuperview];
}

%new
- (void)refreshIcon {
    if (!PXLEnabled) return;

	[self chargePercent];
	icon = nil;
	fill = nil;
	[self cleanUpViews];
	NSData *batteryImage = BATTERY_IMAGE;

	if (!icon) {
        icon = [[UIImageView alloc] initWithFrame:[self bounds]];
        [icon setContentMode:UIViewContentModeScaleAspectFill];
        [icon setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self addSubview:icon];
    }
    float barPercent = 0.00f;
    int tickCt = 0;
    int thresholds[] = {6, 20, 40, 60, 80};
    int tickCounts[] = {1, 2, 3, 4, 5};

    for (int i = sizeof(thresholds) / sizeof(thresholds[0]) - 1; i >= 0; i--) {
        if (actualPercentage >= thresholds[i]) {
            tickCt = tickCounts[i];
            barPercent = (actualPercentage - thresholds[i]) / (i == 0 ? 14.0f : 20.0f);
            break;
        }
    }

    float iconLocationX = icon.frame.origin.x + 2;
    float iconLocationY = icon.frame.origin.y + 2.75;
    float barWidth = (icon.frame.size.width - 6) / 6;
    float barHeight = icon.frame.size.height - 5;

	for (int i = 1; i <= tickCt; ++i){
		CGRect fillFrame = CGRectMake(iconLocationX + ((i-1)*(barWidth + 1)), iconLocationY, (i == tickCt) ? barWidth * barPercent : barWidth, barHeight);
		UIView *fill = [[UIView alloc] initWithFrame:fillFrame];
		[fill setContentMode:UIViewContentModeScaleAspectFill];
		[fill setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

		if ([self saverModeActive]) {
			fill.backgroundColor = LowPowerModeColor;
		} else if (isCharging) {
			fill.backgroundColor = ChargingColor;
		} else if (SingleColorMode && (i >= 1 && i <= 5)) {
			fill.backgroundColor = BatteryColor;
		} else {
			switch (i) {
				case 1:
					fill.backgroundColor = (actualPercentage >= 0) ? Bar1 : nil;
					break;
				case 2:
					fill.backgroundColor = (actualPercentage >= 20) ? Bar2 : nil;
					break;
				case 3:
					fill.backgroundColor = (actualPercentage >= 40) ? Bar3 : nil;
					break;
				case 4:
					fill.backgroundColor = (actualPercentage >= 60) ? Bar4 : nil;
					break;
				case 5:
					if (actualPercentage >= 80) {
						fill.backgroundColor = Bar5;
					} else {
						fill.backgroundColor = (actualPercentage >= 20) ? BatteryColor : LowBatteryColor;
					}
					break;
				default:
					break;
			}
		}

		[self addSubview:fill];
	}

	[icon setImage:[UIImage imageWithData:batteryImage]];
	[self updateIconColor];
}

%new
// Load colors in conditions
- (void)updateIconColor {
    if (!PXLEnabled) return;
    icon.image = [icon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    fill.image = [fill.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIColor *iconTintColor = nil;
    UIColor *fillTintColor = nil;
    if ([self saverModeActive]) {
        iconTintColor = fillTintColor = LowPowerModeColor;
    } else if (isCharging) {
        iconTintColor = fillTintColor = ChargingColor;
    } else {
        if (actualPercentage >= 20) {
            iconTintColor = fillTintColor = BatteryColor;
        } else if (actualPercentage >= 10) {
            iconTintColor = fillTintColor = BatteryColor;
        } else {
            iconTintColor = LowBatteryColor;
            fillTintColor = fill.backgroundColor = LowBatteryColor;
        }
    }
    [icon setTintColor:iconTintColor];
    [fill setTintColor:fillTintColor];
}
%end
%end

%ctor{
	loader();
	%init(PXLBattery);
}
