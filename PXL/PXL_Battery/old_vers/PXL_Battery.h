#import <UIKit/UIKit.h>
#import <QuartzCore/CoreAnimation.h>

//Thank you Litten for BatteryBuddy
//Thanks Paisseon for Vivy

UIImageView* statusBarBatteryIconView;
UIImageView* statusBarBatteryChargerView;
UIImageView* lockscreenBatteryIconView;
UIImageView* lockscreenBatteryChargerView;
BOOL isCharging = NO;
//BOOL isLowPower = NO;
double actualPercentage;
static double percentX;
static double percentY;
//double intBattery;

@interface _UIBatteryView : UIView{
}
@property (nonatomic, copy, readwrite) UIColor* fillColor;
@property (nonatomic, copy, readwrite) UIColor* bodyColor;
@property (nonatomic, copy, readwrite) UIColor* pinColor;
@property (assign,nonatomic) BOOL saverModeActive;

-(CGFloat)chargePercent;
-(long long)chargingState;
-(BOOL)saverModeActive;
-(BOOL)isLowBattery;
//NEW
-(void)refreshIcon;
-(void)updateIconColor;
-(double)getCurrentBattery;
@end

@interface CSBatteryFillView : UIView
@end