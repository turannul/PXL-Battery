#import <UIKit/UIKit.h>
#import <QuartzCore/CoreAnimation.h>

UIImageView* icon;
UIImageView* fill;
UIImageView* lockscreenBatteryIconView;
UIImageView* lockscreenBatteryChargerView;
BOOL isCharging = NO;
double actualPercentage;
static double percentX;
static double percentY;


@interface _UIBatteryView : UIView{}
@property (nonatomic, copy, readwrite) UIColor* fillColor;
@property (nonatomic, copy, readwrite) UIColor* bodyColor;
@property (nonatomic, copy, readwrite) UIColor* pinColor;
@property (assign,nonatomic) BOOL saverModeActive;


-(CGFloat)chargePercent;
-(long long)chargingState;
-(BOOL)saverModeActive;
-(BOOL)isLowBattery;
-(void)refreshIcon;
-(void)updateIconColor;
-(double)getCurrentBattery;
@end

@interface CSBatteryFillView : UIView
@end


