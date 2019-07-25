#import "KenburnsPlugin.h"
#import <kenburns/kenburns-Swift.h>

@implementation KenburnsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftKenburnsPlugin registerWithRegistrar:registrar];
}
@end
