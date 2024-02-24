#define kPrefDomain "xyz.turannul.pxlbattery"
#include "SparkColourPickerUtils.h"
#import "Battery_Images.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/CoreAnimation.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

UIImageView* icon;
UIImageView* fill;
UIImageView* lockscreenBatteryIconView;
UIImageView* lockscreenBatteryChargerView;

UIColor *LowPowerModeColor;
UIColor *ChargingColor;
UIColor *LowBatteryColor;
UIColor *BatteryColor;
UIColor *batteryColorDark;
UIColor *batteryColorLight;
UIColor *Bar1;
UIColor *Bar2;
UIColor *Bar3;
UIColor *Bar4;
UIColor *Bar5;

BOOL isCharging = NO;
BOOL PXLEnabled;
BOOL SingleColorMode;
BOOL statusBarDark;

double actualPercentage;
static double percentX;
static double percentY;

@interface _UIBatteryView : UIView{}

@property (nonatomic, copy, readwrite) UIColor* fillColor;
@property (nonatomic, copy, readwrite) UIColor* bodyColor;
@property (nonatomic, copy, readwrite) UIColor* pinColor;
@property (assign,nonatomic) BOOL saverModeActive;

+(instancetype)sharedInstance;
-(CGFloat)chargePercent;
-(long long)chargingState;
-(double)getCurrentBattery;
-(BOOL)saverModeActive;
-(BOOL)isLowBattery;
-(void)refreshIcon;
-(void)animateSubviewsSequentially:(NSArray *)subviews index:(NSUInteger)index delay:(NSTimeInterval)delay;
-(void)updateIconColor;
-(void)cleanUpViews;
@end