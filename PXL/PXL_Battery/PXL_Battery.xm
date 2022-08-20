#import "PXL_Battery.h"

NSString *img(NSString *img){
	return [NSString stringWithFormat:@"/var/mobile/Library/PXLBattery/%@.png", img];
}

%group PXLBattery

%hook _UIBatteryView
- (bool) _shouldShowBolt {return NO;} // hide charging bolt
- (id) _batteryFillColor {return [UIColor clearColor];} // hide the fill
- (id) bodyColor {return [UIColor clearColor];} // hide the body
- (id) pinColor {return [UIColor clearColor];} // hide the pin
- (CGFloat) bodyColorAlpha {return 0.0;} // hide battery body again
- (CGFloat) pinColorAlpha {return 0.0;} // hide battery pin again

/*-(void)_commonInit{
	%orig;
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:true];// make iOS monitor the battery
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCurrentBattery) name:UIDeviceBatteryLevelDidChangeNotification object:nil];// add observer for battery level
	[self getCurrentBattery];// get charge percent
}*/

/*%new
-(double) getCurrentBattery{
	double currentBattery = [[UIDevice currentDevice] batteryLevel];// the current battery level
	intBattery = currentBattery * 100;// battery level multiplied by 100 for easier casting to int
	locations = @[@0.0, @(currentBattery), @(currentBattery), @1.0];// fill extends from 0% to battery, empty extends from battery to 100%
	//[self addIcon];
	return currentBattery;
}*/

//-----------------------------------------------
-(void)_updateFillLayer{// Keep updating icon
	%orig;
	[self refreshIcon];
}

-(void)setSaverModeActive:(bool)arg1 {
	%orig;
	[self refreshIcon];
}

/*-(UIColor *)boltColor{
	return [UIColor colorWithRed:1.0f green:0.79f blue:0.28f alpha:1.0f];
}*/

-(void)setChargingState:(long long)arg1{
	%orig;
	isCharging = (arg1 == 1); // state of 1 means currently charging
	[self refreshIcon];
}

//-----------------------------------------------

/*-(BOOL)isLowBattery{
	return NO;
}*/
//-----------------------------------------------
/*-(UIColor *)fillColor{// Alpha magic
	return [%orig colorWithAlphaComponent:0.00]; 
}

-(UIColor *)bodyColor{
	return [%orig colorWithAlphaComponent:0.00]; 
}
-(UIColor *)pinColor{
	return [%orig colorWithAlphaComponent:0.00];
}*/
//-----------------------------------------------
// Actual mess is this// maybe not
-(CGFloat)chargePercent{// update corresponding battery percentage
	CGFloat orig = %orig;
	actualPercentage = orig * 100;

	return orig;
}

- (void) didMoveToWindow {
	%orig;
}

%new
-(void)refreshIcon// remove existing images
{
	[self chargePercent];
	icon = nil;
	fill = nil;
	for (UIImageView* imageView in [self subviews]) 
		[imageView removeFromSuperview];

	// face
	if (!icon){
		icon = [[UIImageView alloc] initWithFrame:[self bounds]];
		[icon setContentMode:UIViewContentModeScaleAspectFill];
		[icon setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		if (![icon isDescendantOfView:self]) [self addSubview:icon];
	}

	// charger
	if (!fill){
/*		fill = [[UIImageView alloc] initWithFrame:[self bounds]];
		[fill setContentMode:UIViewContentModeScaleAspectFill];
		[fill setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		//[fill setImage:[UIImage imageWithContentsOfFile:@"var/mobile/Library/PXLBattery/ChargingLS.png"]];
		if (![fill isDescendantOfView:self])
			[self addSubview:fill];*/
		////HERE

		
		
		
		
		
		
		int tickCt = 0;

		if (actualPercentage >= 80)
			tickCt = 5;
		else if (actualPercentage >= 60)
			tickCt = 4;
		else if (actualPercentage >= 40)
			tickCt = 3;
		else if (actualPercentage >= 20)
			tickCt = 2;
		else
			tickCt = 1;

		float iconLocationX = icon.frame.origin.x + 2;
		float iconLocationY = icon.frame.origin.y + 2.75;
		float barWidth = (icon.frame.size.width - 6) / 6;
		float barHeight = icon.frame.size.height - 5;

		for (int i = 1; i <= tickCt; ++i) {
			UIView *fill = [[UIView alloc] initWithFrame: CGRectMake(iconLocationX 
 + ((i-1)*(barWidth + 1))/* / i) - 25*/, iconLocationY, barWidth, barHeight /*(icon.frame.size.width / 5) - (icon.frame.size.width / 15)*/)];
			[fill setContentMode:UIViewContentModeScaleAspectFill];
			[fill setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
			//fill.frame.origin = icon.frame.origin;

		//fill.frame = icon.bounds;
		//fill.frame.size.width = (fill.frame.size.width /i) - 25, 0;
			//fill.layer.borderColor = [UIColor blackColor].CGColor;
			//fill.layer.borderWidth = 1.0f;
			if ([self saverModeActive]){
				if (isCharging){
					fill.backgroundColor = [UIColor blueColor];
				}else{
					fill.backgroundColor = [UIColor yellowColor];
				}
			}else{
				if (isCharging){
					fill.backgroundColor = [UIColor greenColor];
				}else{
					fill.backgroundColor = [UIColor labelColor];
				}
			}
			
			//icon.layer.mask = fill;
			[self addSubview: fill];
		}
		
		
		
		
		
		
		//fill = [[UIImageView alloc] initWithFrame:[self bounds]];
		//[fill setContentMode:UIViewContentModeScaleAspectFill];
		//[fill setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		//[fill setImage:[UIImage imageWithContentsOfFile:@"var/mobile/Library/PXLBattery/ChargingLS.png"]];
//		if (![fill isDescendantOfView:self])
		


//		[icon addSubview:fill];
	}

	NSString *battery = nil;
//	NSString *fill = nil;

/*	if ([self saverModeActive]){
		battery = img(@"LPM");//low power charging
		//  <= = >= 
	}else{*/
/*	if (actualPercentage >= 80){
		battery = img(@"A");
	}else if (actualPercentage >= 60){
		battery = img(@"B");
	}else if (actualPercentage >= 40){
		battery = img(@"C");
	}else if (actualPercentage >= 20){
		battery = img(@"D");
	}else if (actualPercentage >= 10){
		battery = img(@"E");
	}else if (actualPercentage >= 5){*/
		battery = img(@"F");
	/*}else{
		battery = img(@"G");
	}*/
//	}

	[icon setImage:[UIImage imageWithContentsOfFile:battery]];

	[self updateIconColor];
/*	id chargedFill = (id)[[UIColor whiteColor] CGColor]; // use the original image colour for the battery section
	id drainedFill = (id)[[UIColor colorWithWhite:1 alpha:0.5] CGColor]; // faded in uncharged area

	CAGradientLayer* fill = [CAGradientLayer layer];
	fill.frame = icon.bounds;

	fill.colors = @[chargedFill, chargedFill, drainedFill, drainedFill];

	fill.locations = @[@0.0, @(actualPercentage), @(actualPercentage), @1.0];

	fill.startPoint = CGPointZero;
	fill.endPoint = CGPointMake(1.0, 0.0); // end at the end. i am very good at comments. people die if they are killed.
	//[fill setImage:[UIImage imageWithContentsOfFile:fill]];
	icon.layer.mask = fill;*/
}

%new
-(void)updateIconColor{
	icon.image = [icon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	fill.image = [fill.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	if (![self saverModeActive]){
		if (isCharging){
			[icon setTintColor:[UIColor greenColor]];
			[fill setTintColor:[UIColor greenColor]];
		}else{
			if (actualPercentage >= 20){
				[icon setTintColor:[UIColor labelColor]];
				[fill setTintColor:[UIColor labelColor]];
			}else{
				[icon setTintColor:[UIColor labelColor]];
				[fill setTintColor:[UIColor redColor]];
if (actualPercentage >= 10){
[icon setTintColor:[UIColor labelColor]];
[fill setTintColor:[UIColor labelColor]];
}else{
[icon setTintColor:[UIColor redColor]];
[fill setTintColor:[UIColor redColor]];
}
			}
		}
	} else{
		if (isCharging){
			[icon setTintColor:[UIColor greenColor]];
			[fill setTintColor:[UIColor greenColor]];
		}else{
			[icon setTintColor:[UIColor yellowColor]];
			[fill setTintColor:[UIColor yellowColor]];
		}
	}
}



%end
%hook CSBatteryFillView
//Lock screen?
//target make gif when plugged 
%end

%end

%ctor{
	%init(PXLBattery);
}
