#include <Foundation/Foundation.h>

#define kPrefDomain "xyz.turannul.pxlbattery"///var/mobile/Library/Preferences/xyz.turannul.pxlbattery.plist

@interface pxlSettings : NSObject{
 
}
@property (nonatomic, copy) NSMutableDictionary *preferences;

-(BOOL)pxlEnabled; //enabled? maybe not lets check
@end
