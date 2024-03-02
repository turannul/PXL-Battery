// NSTask.h
#import <Foundation/NSObject.h>

@class NSString, NSArray, NSDictionary;

@interface NSTask : NSObject

-(instancetype)init;
-(void)setLaunchPath:(NSString *)path;
-(void)setArguments:(NSArray *)arguments;
-(void)setEnvironment:(NSDictionary *)dict;
-(void)setCurrentDirectoryPath:(NSString *)path;
-(void)setStandardInput:(id)input;
-(void)setStandardOutput:(id)output;
-(void)setStandardError:(id)error;
-(NSString *)launchPath;
-(NSArray *)arguments;
-(NSDictionary *)environment;
-(NSString *)currentDirectoryPath;
-(id)standardInput;
-(id)standardOutput;
-(id)standardError;
-(void)launch;
-(void)interrupt;
-(void)terminate;
-(BOOL)suspend;
-(BOOL)resume;
-(int)processIdentifier;
-(BOOL)isRunning;
-(int)terminationStatus;

@end