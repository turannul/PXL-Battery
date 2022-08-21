#import "PXL_Battery.h"
#import "PXL_Settings.h"

NSString *img(NSString *img){
	return [NSString stringWithFormat:@"/var/mobile/Library/PXLBattery/%@.png", img];
}

%group PXLBattery
%hook _UIBatteryView

- (bool) _showsInlineChargingIndicator {return NO;}
- (bool) _shouldShowBolt {return NO;} // hide charging bolt
- (id) _batteryFillColor {return [UIColor clearColor];} // hide the fill
- (id) bodyColor {return [UIColor clearColor];} // hide the body
- (id) pinColor {return [UIColor clearColor];} // hide the pin
- (CGFloat) bodyColorAlpha {return 0.0;} // hide battery body again
- (CGFloat) pinColorAlpha {return 0.0;} // hide battery pin again

//-----------------------------------------------
// Keep refreshing 

-(void)_updateFillLayer
{ 
	[self refreshIcon]; 
}

-(void)setSaverModeActive:(bool)arg1 {
	%orig;
	[self refreshIcon];
}

-(void)setChargingState:(long long)arg1{
	%orig;
	isCharging = (arg1 == 1); // state of 1 means currently charging
	[self refreshIcon];
}
//-----------------------------------------------
// Main
-(CGFloat)chargePercent{// update corresponding battery percentage
	CGFloat orig = %orig;
	actualPercentage = orig * 100;

	return orig;
}

- (void) didMoveToWindow 
{
	[self refreshIcon];
}

%new
-(void)refreshIcon// remove existing images
{
	[self chargePercent];
	icon = nil;
	fill = nil;
	for (UIImageView* imageView in [self subviews]) 
		[imageView removeFromSuperview];

	if (!icon){
		icon = [[UIImageView alloc] initWithFrame:[self bounds]];
		[icon setContentMode:UIViewContentModeScaleAspectFill];
		[icon setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		if (![icon isDescendantOfView:self]) [self addSubview:icon];
	}

	if (!fill){
		int tickCt = 0;

		if (actualPercentage >= 80)
			tickCt = 5;
		else if (actualPercentage >= 60)
			tickCt = 4;
		else if (actualPercentage >= 40)
			tickCt = 3;
		else if (actualPercentage >= 20)
			tickCt = 2;
		else if (actualPercentage >= 10)
			tickCt = 1;
      else 
         tickCt = 0;

//You died, rejailbreak now!

		float iconLocationX = icon.frame.origin.x + 2;
		float iconLocationY = icon.frame.origin.y + 2.75;
		float barWidth = (icon.frame.size.width - 6) / 6;
		float barHeight = icon.frame.size.height - 5;

		for (int i = 1; i <= tickCt; ++i) {
			UIView *fill = [[UIView alloc] initWithFrame: CGRectMake(iconLocationX 
 + ((i-1)*(barWidth + 1)), iconLocationY, barWidth, barHeight)];
			[fill setContentMode:UIViewContentModeScaleAspectFill];
			[fill setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

//-----------------------------------------------
			// Colors
if ([self saverModeActive]){
if (isCharging){
//Yellow
fill.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:2.0/255.0 alpha:1.0f];
				}else{
//Yellow
fill.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:2.0/255.0 alpha:1.0f];
				}
			}else{
				if (isCharging){
//Green
fill.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:12.0/255.0 alpha:1.0f];
				}else{
					if (actualPercentage >= 20)
fill.backgroundColor = [UIColor labelColor];
					else
//Red
fill.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:51.0/255.0 blue:35.0/255.0 alpha:1.0f];
				}
			}
			[self addSubview: fill];
		}
	}

//-----------------------------------------------
	// Frame
	NSString *battery = nil;

		battery = img(@"F");

	[icon setImage:[UIImage imageWithContentsOfFile:battery]];

	[self updateIconColor];
	}
//-----------------------------------------------
%new
-(void)updateIconColor{
	icon.image = [icon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	fill.image = [fill.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]; //commented before.

if (![self saverModeActive]){
if (isCharging){
[icon setTintColor:[UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:12.0/255.0 alpha:1.0f]];
[fill setTintColor:[UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:12.0/255.0 alpha:1.0f]];
}else{
if (actualPercentage >= 20){
[icon setTintColor:[UIColor labelColor]];
[fill setTintColor:[UIColor labelColor]];
}else{
[icon setTintColor:[UIColor labelColor]];
[fill setTintColor:fill.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:51.0/255.0 blue:35.0/255.0 alpha:1.0f]];
if (actualPercentage >= 10){
[icon setTintColor:[UIColor labelColor]];
[fill setTintColor:[UIColor labelColor]];
}else{
[icon setTintColor:fill.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:51.0/255.0 blue:35.0/255.0 alpha:1.0f]];
[fill setTintColor:fill.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:51.0/255.0 blue:35.0/255.0 alpha:1.0f]];
}
			}
		}
	} else{
		if (isCharging){
			[icon setTintColor:[UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:12.0/255.0 alpha:1.0f]];
			[fill setTintColor:[UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:12.0/255.0 alpha:1.0f]];
		}else{
			[icon setTintColor:[UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:2.0/255.0 alpha:1.0f]];
			[fill setTintColor:[UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:2.0/255.0 alpha:1.0f]];
		}
	}
}

%end
%end

%ctor{
	pxlSettings *_settings = [[pxlSettings alloc] init];
	BOOL pxlEnabled = [_settings pxlEnabled];
	if (pxlEnabled)
		%init(PXLBattery);
}
