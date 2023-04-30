#define kPrefDomain "xyz.turannul.pxlbattery"
#include "SparkColourPickerUtils.h"
#import <QuartzCore/CoreAnimation.h>
#import <UIKit/UIKit.h>
#import "Battery_Images.h"

UIImageView* icon;
UIImageView* fill;
UIImageView* lockscreenBatteryIconView;
UIImageView* lockscreenBatteryChargerView;

UIColor *LowPowerModeColor;
UIColor *ChargingColor;
UIColor *LowBatteryColor;
UIColor *BatteryColor;

BOOL isCharging = NO;
BOOL PXLEnabled;

double actualPercentage;
static double percentX;
static double percentY;

@interface _UIBatteryView : UIView{
}
@property (nonatomic, copy, readwrite) UIColor* fillColor;
@property (nonatomic, copy, readwrite) UIColor* bodyColor;
@property (nonatomic, copy, readwrite) UIColor* pinColor;
@property (assign,nonatomic) BOOL saverModeActive;

+(instancetype)sharedInstance;
-(CGFloat)chargePercent;
-(long long)chargingState;
-(BOOL)saverModeActive;
-(BOOL)isLowBattery;
-(void)refreshIcon;
-(void)updateIconColor;
-(double)getCurrentBattery;
-(void)cleanUpViews;
@end