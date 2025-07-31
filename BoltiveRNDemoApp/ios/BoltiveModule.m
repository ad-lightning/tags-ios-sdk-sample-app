//
//  BoltiveModule.m
//  BoltiveRNDemoApp
//
//  Created by Olena Stepaniuk on 23.06.2025.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTUIManager.h>

@interface RCT_EXTERN_MODULE(BoltiveModule, NSObject)

RCT_EXTERN_METHOD(initialize:(NSString *)clientId
                  adNetwork:(NSString *)adNetwork
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(captureBanner:(nonnull NSNumber *)reactTag
                  tagDetails:(NSDictionary *)tagDetails
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
