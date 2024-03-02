#define kPrefDomain "xyz.turannul.PXLBattery"
#pragma GCC diagnostic ignored "-Wunused-function"
#include "SparkColourPickerUtils.h"
#import "batteryFrame_img.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/CoreAnimation.h>
#import <QuartzCore/QuartzCore.h>

UIImageView* batteryIcon;
UIColor *batteryIcon_TintColor = nil;
UIImageView* batteryBar;
UIColor *batteryBar_TintColor = nil;

float batteryBar_Percentage = 0.00f;
int batteryBar_Count = 0;
int batteryBar_thresholds[] = { 6, 20, 40, 60, 80 };
int batteryBar_array[] = { 1, 2, 3, 4, 5 };

float batteryFrameLocation_X = batteryIcon.frame.origin.x + 2;
float batteryFrameLocation_Y = batteryIcon.frame.origin.y + 2.75;

NSData *batteryFrame_img = frame_img_data;

UIColor *LowPowerModeColor;
UIColor *ChargingColor;
UIColor *LowBatteryColor;
UIColor *BatteryColor;
UIColor *Bar1;
UIColor *Bar2;
UIColor *Bar3;
UIColor *Bar4;
UIColor *Bar5;

BOOL isCharging;
BOOL PXLEnabled;
BOOL SingleColorMode;
BOOL StatusBarStyle;

double BatteryLevel;
static double percentX;
static double percentY;

@interface _UIBatteryView : UIView {}

@property (nonatomic, copy, readwrite) UIColor* fillColor;
@property (nonatomic, copy, readwrite) UIColor* bodyColor;
@property (nonatomic, copy, readwrite) UIColor* pinColor;
@property (assign,nonatomic) BOOL saverModeActive;

+(instancetype)sharedInstance;
-(CGFloat)chargePercent;
-(long long)chargingState;
-(BOOL)saverModeActive;
-(void)Refresh_batteryIcon;
-(void)Refresh_batteryIcon_Color;
-(void)cleanUpViews;
@end