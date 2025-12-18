//
//  MPKitMixpanelObjC.m
//  mParticle-Mixpanel
//
//  Objective-C wrapper for automatic kit registration.
//

#import "MPKitMixpanelObjC.h"

#ifdef COCOAPODS
#import "mParticle_Mixpanel/mParticle_Mixpanel-Swift.h"
#elif SWIFT_PACKAGE
@import mParticle_Mixpanel;
#else
#error "Package manager not supported"
#endif

@import mParticle_Apple_SDK;

@implementation MPKitMixpanelObjC

+ (void)load {
    NSString *className = NSStringFromClass([MPKitMixpanel class]);
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Mixpanel" className:className];
    [MParticle registerExtension:kitRegister];
}

@end
