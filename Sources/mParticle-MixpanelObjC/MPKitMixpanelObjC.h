//
//  MPKitMixpanelObjC.h
//  mParticle-Mixpanel
//
//  Objective-C wrapper for automatic kit registration.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// Objective-C wrapper that registers the Mixpanel kit with mParticle.
/// This class uses +load to ensure automatic registration when the library is loaded.
@interface MPKitMixpanelObjC : NSObject

@end

NS_ASSUME_NONNULL_END
