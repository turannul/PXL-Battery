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
    if (!PXLEnabled) {
        %orig;
        return;
    }

	// TODO: make same animation for < 6% * How to animate frame?
	// Charging effect (broken/unefficient)
	BOOL Charging = (actualPercentage >= 6) && (actualPercentage != 100) && (isCharging);
	BOOL LowBattery = (actualPercentage <= 20) && (!isCharging);
	// BOOL BatteryTooLow = (actualPercentage <= 6) && (!isCharging);
	if (Charging || LowBattery) {
        NSInteger tickCount = (NSInteger)(actualPercentage / 20);
			NSMutableArray *subviewsToAnimate = [NSMutableArray array];
			for (UIView *subview in self.subviews) {
				if (![subview isKindOfClass:[UIImageView class]]) {[subviewsToAnimate addObject:subview];}}
			__block NSInteger ticksToShow = Charging ? 5 : 0;
			NSTimer *animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
				for (NSInteger i = 0; i < subviewsToAnimate.count; i++) {
					UIView *subview = subviewsToAnimate[i];
					dispatch_async(dispatch_get_main_queue(), ^{ subview.hidden = (i >= ticksToShow); });}
				if (ticksToShow < tickCount) { ticksToShow++; } else { ticksToShow--; }}];
			[[NSRunLoop currentRunLoop] addTimer:animationTimer forMode:NSRunLoopCommonModes];}
	[self refreshIcon];
}
	//if (BatteryTooLow) {
		// Same animation on UIImageView 
//	}

// when low power mode activated
-(void)setSaverModeActive:(bool)arg1{
	%orig;
	if (PXLEnabled)
		[self refreshIcon];
}

// when charger plugged
-(void)setChargingState:(long long)arg1{
	%orig;
	isCharging = (arg1 == 1); // 1 = Charging
	if (PXLEnabled)
		[self refreshIcon];
}

//-----------------------------------------------
//Update corresponding battery percentage
-(CGFloat)chargePercent{
	CGFloat orig = %orig;
	actualPercentage = orig * 100;

	return orig;
}

%new
-(void)cleanUpViews{
	for (UIImageView* imageView in [self subviews])
		[imageView removeFromSuperview];
}

%new
-(void)refreshIcon{
	if (!PXLEnabled)
		return;

	[self chargePercent];
	icon = nil;
	fill = nil;

	[self cleanUpViews];

	NSData *batteryImage = BATTERY_IMAGE;

	if (!icon){
		icon = [[UIImageView alloc] initWithFrame:[self bounds]];
		[icon setContentMode:UIViewContentModeScaleAspectFill];
		[icon setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[self addSubview:icon];
	}

	float barPercent = 0.00f;
	int tickCt = 0;

	if (actualPercentage >= 80){
		tickCt = 5;
		barPercent = ((actualPercentage - 80) / 20.00f);
	}else if (actualPercentage >= 60){
		tickCt = 4;
		barPercent = ((actualPercentage - 60) / 20.00f);
	}else if (actualPercentage >= 40){
		tickCt = 3;
		barPercent = ((actualPercentage - 40) / 20.00f);
	}else if (actualPercentage >= 20){
		tickCt = 2;
		barPercent = ((actualPercentage - 20) / 20.00f);
	}else if (actualPercentage >= 6){
		tickCt = 1;
		barPercent = ((actualPercentage - 6) / 14.00f);
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

		if ([self saverModeActive]){
			fill.backgroundColor = LowPowerModeColor;
		}else if (isCharging){
			fill.backgroundColor = ChargingColor;
		}else if (SingleColorMode && (i >= 1 && i <= 5)){
			fill.backgroundColor = BatteryColor;
		}else if (i == 1 && actualPercentage >=  0){ 
			fill.backgroundColor = Bar1;
		}else if (i == 2 && actualPercentage >= 20){
			fill.backgroundColor = Bar2;
		}else if (i == 3 && actualPercentage >= 40){
			fill.backgroundColor = Bar3;
		}else if (i == 4 && actualPercentage >= 60){
			fill.backgroundColor = Bar4;
		}else if (i == 5 && actualPercentage >= 80){
			fill.backgroundColor = Bar5;
			if (actualPercentage >= 20)
				fill.backgroundColor = BatteryColor;
			else
				fill.backgroundColor = LowBatteryColor;
		}

		[self addSubview:fill];
	}

	[icon setImage:[UIImage imageWithData:batteryImage]];
	[self updateIconColor];
}

%new
// Load colors in conditions
-(void)updateIconColor{
	if (!PXLEnabled)
		return;

	icon.image = [icon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]; 
	fill.image = [fill.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	if (![self saverModeActive]){
		if (isCharging){
			[icon setTintColor:ChargingColor];
			[fill setTintColor:ChargingColor];
		}else{
			if (actualPercentage >= 20){
				[icon setTintColor:BatteryColor];
				[fill setTintColor:BatteryColor];
			}else{
				[icon setTintColor:fill.backgroundColor = BatteryColor];
				[fill setTintColor:fill.backgroundColor = LowBatteryColor];
				if (actualPercentage >= 10){
					[icon setTintColor:BatteryColor];
					[fill setTintColor:BatteryColor];
				}else{
					[icon setTintColor:fill.backgroundColor = LowBatteryColor];
					[fill setTintColor:fill.backgroundColor = LowBatteryColor];

				}
			}
		}
	}else{
		if (isCharging){
			[icon setTintColor:fill.backgroundColor = ChargingColor];
			[fill setTintColor:fill.backgroundColor = ChargingColor];

		}else{
			[icon setTintColor:fill.backgroundColor = LowPowerModeColor];
			[fill setTintColor:fill.backgroundColor = LowPowerModeColor];
		}
	}
}
/* 
Explanation required in depth because, too many if else confusing here is what does:
This code sets colors for battery icon (frame) & fill (tick). 
Colors are determined by whether device is in low power mode, charging, or has a certain battery percentage. 
If device is in low power mode, colors will be set to LowPowerModeColor. 
If charging = 1, colors will be set to ChargingColor. 
If device has a battery percentage of 20% or greater, colors will be set to BatteryColor. 
If device has a battery percentage of less than 20%, colors will be set to LowBatteryColor. 
Code sets both tint color of icon (frame) & fill (tick) using appropriate color value.
*/
%end
%end

%ctor{
	loader();
	%init(PXLBattery);
}
