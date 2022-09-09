#import "PXL_Battery.h"
#import "PXL_Settings.h"

#define RED [UIColor colorWithRed:234.0/255.0 green:51.0/255.0 blue:35.0/255.0 alpha:1.0f]
#define GREEN [UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:12.0/255.0 alpha:1.0f]
#define YELLOW [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:2.0/255.0 alpha:1.0f]

static void loader() {
	pxlSettings *_settings = [[pxlSettings alloc] init];
	PXLEnabled = [_settings pxlEnabled];
	if (customViewApplied){
		[[_UIBatteryView sharedInstance] cleanUpViews];
		customViewApplied = NO;
	}
}

%group PXLBattery // Here go again

%hook _UIStaticBatteryView  // Control Center Battery
-(bool) _showsInlineChargingIndicator{return PXLEnabled?NO:%orig;}     // Hide charging bolt
-(bool) _shouldShowBolt{return PXLEnabled?NO:%orig;}                   // Hide charging bolt x2
-(id) _batteryFillColor{return PXLEnabled?[UIColor clearColor]:%orig;} // Hide the fill
-(id) bodyColor{return PXLEnabled?[UIColor clearColor]:%orig;}         // Hide the body
-(id) pinColor{return PXLEnabled?[UIColor clearColor]:%orig;}          // Hide the pin
-(CGFloat) bodyColorAlpha{return PXLEnabled?0.0:%orig;}                // Hide battery body x2
-(CGFloat) pinColorAlpha{return PXLEnabled?0.0:%orig;}                 // Hide battery pin x2
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

-(BOOL)_showsInlineChargingIndicator{return PXLEnabled?NO:%orig;}     // Hide charging bolt
-(BOOL)_shouldShowBolt{return PXLEnabled?NO:%orig;}                   // Hide charging bolt x2
-(id)_batteryFillColor{return PXLEnabled?[UIColor clearColor]:%orig;} // Hide the fill
-(id)bodyColor{return PXLEnabled?[UIColor clearColor]:%orig;}         // Hide the body
-(id)pinColor{return PXLEnabled?[UIColor clearColor]:%orig;}          // Hide the pin
-(CGFloat)bodyColorAlpha{return PXLEnabled?0.0:%orig;}                // Hide battery body x2
-(CGFloat)pinColorAlpha{return PXLEnabled?0.0:%orig;}                 // Hide battery pin x2

//-----------------------------------------------
//Keep refreshing

-(void)_updateFillLayer{
	if (PXLEnabled)
		[self refreshIcon];
	else
		%orig;
}

-(void)setSaverModeActive:(bool)arg1{
	%orig;
	if (PXLEnabled)
		[self refreshIcon];
}

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
	if (PXLEnabled){
		[self chargePercent];
		icon = nil;
		fill = nil;

// Frame as base64
		[self cleanUpViews];

		NSData* batteryImage = [[NSData alloc] initWithBase64EncodedString:@"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" options:0];


		if (!icon){
			icon = [[UIImageView alloc] initWithFrame:[self bounds]];
			[icon setContentMode:UIViewContentModeScaleAspectFill];
			[icon setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
			if (![icon isDescendantOfView:self])[self addSubview:icon];
		}

		if (!fill){
			int tickCt = 0;

			if (actualPercentage >= 85)
				tickCt = 5;
			else if (actualPercentage >= 65)
				tickCt = 4;
			else if (actualPercentage >= 50)
				tickCt = 3;
			else if (actualPercentage >= 30)
				tickCt = 2;
			else if (actualPercentage >= 10)
				tickCt = 1;
			else
				tickCt = 0; //You died, R.I.P.. 

			float iconLocationX = icon.frame.origin.x + 2;
			float iconLocationY = icon.frame.origin.y + 2.75;
			float barWidth = (icon.frame.size.width - 6) / 6;
			float barHeight = icon.frame.size.height - 5;

			for (int i = 1; i <= tickCt; ++i){
				UIView *fill = [[UIView alloc] initWithFrame:CGRectMake(iconLocationX + ((i-1) * (barWidth + 1)), iconLocationY, barWidth, barHeight)];
				[fill setContentMode:UIViewContentModeScaleAspectFill];
				[fill setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

//-----------------------------------------------
//Colors
				if ([self saverModeActive]){
					fill.backgroundColor = YELLOW;
				}else{
					if (isCharging){
						fill.backgroundColor = GREEN;
					}else{
						if (actualPercentage >= 20)
							fill.backgroundColor = [UIColor labelColor];
						else
							fill.backgroundColor = RED;
					}
				}
				[self addSubview:fill];
			}
		}

//-----------------------------------------------
//Loading Frame
		[icon setImage:[UIImage imageWithData:batteryImage]];

		[self updateIconColor];
		customViewApplied=YES;
	}
}
//-----------------------------------------------
%new
-(void)updateIconColor{
	if (PXLEnabled){
		icon.image = [icon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		fill.image = [fill.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		
		if (![self saverModeActive]){
			if (isCharging){
				[icon setTintColor:GREEN];
				[fill setTintColor:GREEN];
			}else{
				if (actualPercentage >= 20){
					[icon setTintColor:[UIColor labelColor]];
					[fill setTintColor:[UIColor labelColor]];
				}else{
					[icon setTintColor:[UIColor labelColor]];
					[fill setTintColor:fill.backgroundColor = RED];
					if (actualPercentage >= 10){
						[icon setTintColor:[UIColor labelColor]];
						[fill setTintColor:[UIColor labelColor]];
					}else{
						[icon setTintColor:fill.backgroundColor = RED];
						[fill setTintColor:fill.backgroundColor = RED];
					}
				}
			}
		}else{
			if (isCharging){
				[icon setTintColor:GREEN];
				[fill setTintColor:GREEN];
			}else{
				[icon setTintColor:YELLOW];
				[fill setTintColor:YELLOW];
			}
		}
	}
}

%end
%end

%ctor{
	loader();
//	if (PXLEnabled)
	%init(PXLBattery);

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loader, CFSTR("xyz.turannul.pxlbattery.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
