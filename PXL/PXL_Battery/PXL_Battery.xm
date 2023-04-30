#import "PXL_Battery.h"

static NSString *GetNSString(NSString *pkey, NSString *defaultValue){
	NSDictionary *Dict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", @kPrefDomain]];
	
	return [Dict objectForKey:pkey] ? [Dict objectForKey:pkey] : defaultValue;
}

static BOOL GetBool(NSString *pkey, BOOL defaultValue){
	NSDictionary *Dict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", @kPrefDomain]];

	return [Dict objectForKey:pkey] ? [[Dict objectForKey:pkey] boolValue] : defaultValue;
}

static void loader(){
	PXLEnabled = GetBool(@"pxlEnabled", YES);

	NSString *Color = GetNSString(@"BatteryColor", @"#FFFFFF");
	BatteryColor = [SparkColourPickerUtils colourWithString:Color withFallback:@"#FFFFFF"];

	Color = GetNSString(@"LowPowerModeColor", @"#FFCC02");
	LowPowerModeColor = [SparkColourPickerUtils colourWithString:Color withFallback:@"#FFCC02"];

	Color = GetNSString(@"LowBatteryColor", @"#EA3323");
	LowBatteryColor = [SparkColourPickerUtils colourWithString:Color withFallback:@"#EA3323"];

	Color = GetNSString(@"ChargingColor", @"#00FF0C");
	ChargingColor = [SparkColourPickerUtils colourWithString:Color withFallback:@"#00FF0C"];
}

%group PXLBattery // Here go again
%hook _UIStaticBatteryView// Control Center Battery
-(bool) _showsInlineChargingIndicator{return PXLEnabled?NO:%orig;} // Hide charging bolt
-(bool) _shouldShowBolt{return PXLEnabled?NO:%orig;} // Hide charging bolt x2
-(id) bodyColor{return PXLEnabled?[UIColor clearColor]:%orig;} // Hide the body
-(CGFloat) bodyColorAlpha{return PXLEnabled?0.0:%orig;}// Hide the body x2
-(id) pinColor{return PXLEnabled?[UIColor clearColor]:%orig;}// Hide the pin
-(CGFloat) pinColorAlpha{return PXLEnabled?0.0:%orig;} // Hide battery pin x2
-(id) _batteryFillColor{return PXLEnabled?[UIColor clearColor]:%orig;} // Hide the fill

-(void)_updateFillLayer{
	PXLEnabled?[self refreshIcon]:%orig; 
}
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

-(BOOL)_showsInlineChargingIndicator{return PXLEnabled?NO:%orig;} // Hide charging bolt
-(BOOL)_shouldShowBolt{return PXLEnabled?NO:%orig;} // Hide charging bolt x2
-(id)bodyColor{return PXLEnabled?[UIColor clearColor]:%orig;} // Hide the body
-(CGFloat)bodyColorAlpha{return PXLEnabled?0.0:%orig;}// Hide the body x2
-(id)pinColor{return PXLEnabled?[UIColor clearColor]:%orig;}// Hide the pin
-(CGFloat)pinColorAlpha{return PXLEnabled?0.0:%orig;} // Hide the pin x2
-(id)_batteryFillColor{return PXLEnabled?[UIColor clearColor]:%orig;} // Hide the fill

//-----------------------------------------------
//Keep updating view

-(void)_updateFillLayer{
	if (PXLEnabled)
		[self refreshIcon];
	else
		%orig;
}
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
-(CGFloat)chargePercent
{
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

// Frame as base64
	[self cleanUpViews];

	NSData *batteryImage = BATTERY_IMAGE;
	NSData *batteryLowImage = BATTERY_LOW_IMAGE;

	if (!icon){
		icon = [[UIImageView alloc] initWithFrame:[self bounds]];
		[icon setContentMode:UIViewContentModeScaleAspectFill];
		[icon setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		if (![icon isDescendantOfView:self])
			[self addSubview:icon];
	}
// Update tick count in battery %
	float barPercent = 0.00f;
	if (!fill){
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
		}else{
			tickCt = 0;
		}

		float iconLocationX = icon.frame.origin.x + 2;
		float iconLocationY = icon.frame.origin.y + 2.75;
		float barWidth = (icon.frame.size.width - 6) / 6;
		float barHeight = icon.frame.size.height - 5;

		for (int i = 1; i <= tickCt; ++i){
			UIView *fill;
			if (i == tickCt)
				fill = [[UIView alloc] initWithFrame: CGRectMake(iconLocationX + ((i-1)*(barWidth + 1)), iconLocationY, barWidth * barPercent, barHeight)];
			else
				fill = [[UIView alloc] initWithFrame: CGRectMake(iconLocationX + ((i-1)*(barWidth + 1)), iconLocationY, barWidth, barHeight)];
			[fill setContentMode:UIViewContentModeScaleAspectFill];
			[fill setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];	
//-----------------------------------------------
//Colors
	if ([self saverModeActive]){
		fill.backgroundColor = LowPowerModeColor;
	} else {
		if (isCharging){
			fill.backgroundColor = ChargingColor;
		} else {
			if (actualPercentage >= 20)
				fill.backgroundColor = BatteryColor;  
			else 
				fill.backgroundColor = LowBatteryColor;
					[self addSubview:fill];
			}
		}
	}
		}
//-----------------------------------------------
//Loading Frame
	if (actualPercentage >= 6)
		[icon setImage:[UIImage imageWithData:batteryImage]];
	else
		[icon setImage:[UIImage imageWithData:batteryLowImage]];

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