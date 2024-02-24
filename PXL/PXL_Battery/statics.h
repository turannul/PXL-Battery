#import "PXL_Battery.h"

static NSString *GetNSString(NSString *pkey, NSString *defaultValue){
	NSDictionary *Dict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", @kPrefDomain]];
	return [Dict objectForKey:pkey] ? [Dict objectForKey:pkey] : defaultValue;
}

static BOOL GetBool(NSString *pkey, BOOL defaultValue){
	NSDictionary *Dict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", @kPrefDomain]];
	return [Dict objectForKey:pkey] ? [[Dict objectForKey:pkey] boolValue] : defaultValue;
}

static UIColor *invertColor(UIColor *originalColor){
	CGFloat red, green, blue, alpha;
	[originalColor getRed:&red green:&green blue:&blue alpha:&alpha];

	UIColor *invertedColor = [UIColor colorWithRed:(1.0 - red) green:(1.0 - green) blue:(1.0 - blue) alpha:alpha];

	return invertedColor;
}

static void loader(){
	PXLEnabled = GetBool(@"pxlEnabled", YES);
	SingleColorMode = GetBool(@"SingleColorMode",YES);
	UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager;
	UIStatusBarStyle statusBarStyle = statusBarManager.statusBarStyle;

	statusBarDark = statusBarStyle != UIStatusBarStyleLightContent;

	UIColor *colorValues[] = {
		[SparkColourPickerUtils colourWithString:GetNSString(@"BatteryColor", @"#FFFFFF") withFallback:@"#FFFFFF"],
		[SparkColourPickerUtils colourWithString:GetNSString(@"LowPowerModeColor", @"#FFCC02") withFallback:@"#FFCC02"],
		[SparkColourPickerUtils colourWithString:GetNSString(@"LowBatteryColor", @"#EA3323") withFallback:@"#EA3323"],
		[SparkColourPickerUtils colourWithString:GetNSString(@"ChargingColor", @"#00FF0C") withFallback:@"#00FF0C"],
		[SparkColourPickerUtils colourWithString:GetNSString(@"Bar1", @"#FFFFFF") withFallback:@"#FFFFFF"],
		[SparkColourPickerUtils colourWithString:GetNSString(@"Bar2", @"#FFFFFF") withFallback:@"#FFFFFF"],
		[SparkColourPickerUtils colourWithString:GetNSString(@"Bar3", @"#FFFFFF") withFallback:@"#FFFFFF"],
		[SparkColourPickerUtils colourWithString:GetNSString(@"Bar4", @"#FFFFFF") withFallback:@"#FFFFFF"],
		[SparkColourPickerUtils colourWithString:GetNSString(@"Bar5", @"#FFFFFF") withFallback:@"#FFFFFF"]
	};

	NSUInteger numberOfColors = sizeof(colorValues) / sizeof(colorValues[0]);

	for (NSUInteger i = 0; i < numberOfColors; i++) {
		UIColor *currentColor = colorValues[i];

		if (!statusBarDark)
			currentColor = invertColor(currentColor);

		// Assign the color variable based on the index 'i'
		switch (i) {
			case 0:
				BatteryColor = currentColor;
				break;
			case 1:
				LowPowerModeColor = currentColor;
				break;
			case 2:
				LowBatteryColor = currentColor;
				break;
			case 3:
				ChargingColor = currentColor;
				break;
			case 4:
				Bar1 = currentColor;
				break;
			case 5:
				Bar2 = currentColor;
				break;
			case 6:
				Bar3 = currentColor;
				break;
			case 7:
				Bar4 = currentColor;
				break;
			case 8:
				Bar5 = currentColor;
				break;
			default:
				break;
		}
	}
}