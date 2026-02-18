#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface TesseractWrapper : NSObject

- (instancetype)init;
- (NSString *)recognizeImage:(NSImage *)image;

@end
