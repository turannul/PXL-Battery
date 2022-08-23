#import "PXL_Settings.h"
#import <notify.h>

@interface pxlSettings ()
@property (nonatomic, readonly) int token;
@end

@implementation pxlSettings
@synthesize preferences = _preferences;

-(instancetype)init {
 if(self = [super init]) {

  [self registerDefaults];

  int token = 0;
  __block pxlSettings *blockSelf = self;
  notify_register_dispatch(kPrefDomain, &token, dispatch_get_main_queue(), ^(int token) {
   blockSelf->_preferences = nil;
  });
  _token = token;
 }
 return self;
}

-(void)dealloc {
	[super dealloc];
 notify_cancel(self.token);
}

-(void)registerDefaults {
 if(!CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("pxlEnabled"), CFSTR(kPrefDomain)))) {
  CFPreferencesSetAppValue((CFStringRef)@"pxlEnabled", (CFPropertyListRef)@1, CFSTR(kPrefDomain));
 }
}

-(NSMutableDictionary *)preferences {
 if (!_preferences) {
  CFStringRef appID = CFSTR(kPrefDomain);
  CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
  if (!keyList) return nil;
  _preferences = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
  CFRelease(keyList);
 }

 return _preferences;
}

-(BOOL)pxlEnabled
{return (self.preferences[@"pxlEnabled"] ? [self.preferences[@"pxlEnabled"] boolValue] : YES);}
@end
