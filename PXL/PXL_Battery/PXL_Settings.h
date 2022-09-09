#include <Foundation/Foundation.h>
#define kPrefDomain "xyz.turannul.pxlbattery"

BOOL PXLEnabled;

@interface pxlSettings : NSObject{}
@property (nonatomic, copy) NSMutableDictionary *preferences;

-(BOOL)pxlEnabled; //enabled? maybe not lets check
@end