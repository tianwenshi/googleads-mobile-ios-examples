//
//  GADMInterstitialApplins.m
//  GPADMOB
//
//  Created by 兰旭平 on 2017/11/14.
//  Copyright © 2017年 MySDK.com. All rights reserved.
//

#import "GADMInterstitialApplins.h"
#import <ApplinsSDK/ApplinsSDK.h>
#include <stdatomic.h>

@interface GADMInterstitialApplins () <GADMediationAdapter, ALSAdViewDelegate, GADMediationInterstitialAd> {
  /// The completion handler to call when the ad loading succeeds or fails.
  GADMediationInterstitialLoadCompletionHandler _loadCompletionHandler;

  /// The ad event delegate to forward ad rendering events to the Google Mobile Ads SDK.
  id<GADMediationInterstitialAdEventDelegate> _adEventDelegate;
}

@end

@implementation GADMInterstitialApplins

#pragma mark GADCustomEventInterstitial implementation


+ (void)setUpWithConfiguration:(GADMediationServerConfiguration *)configuration
             completionHandler:(GADMediationAdapterSetUpCompletionBlock)completionHandler {
  // This is where you you will initialize the SDK that this custom event is built for.
  // Upon finishing the SDK initialization, call the completion handler with success.
  completionHandler(nil);
}

+ (GADVersionNumber)adSDKVersion {
  GADVersionNumber version = {0};
  return version;
}

+ (GADVersionNumber)adapterVersion {
  GADVersionNumber version = {2.0};
  return version;
}

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
  return Nil;
}

- (void)loadInterstitialForAdConfiguration:
            (GADMediationInterstitialAdConfiguration *)adConfiguration
                         completionHandler:
                             (GADMediationInterstitialLoadCompletionHandler)completionHandler {
  __block atomic_flag completionHandlerCalled = ATOMIC_FLAG_INIT;
  __block GADMediationInterstitialLoadCompletionHandler originalCompletionHandler =
      [completionHandler copy];

  _loadCompletionHandler = ^id<GADMediationInterstitialAdEventDelegate>(
      _Nullable id<GADMediationInterstitialAd> ad, NSError *_Nullable error) {
    // Only allow completion handler to be called once.
    if (atomic_flag_test_and_set(&completionHandlerCalled)) {
      return nil;
    }

    id<GADMediationInterstitialAdEventDelegate> delegate = nil;
    if (originalCompletionHandler) {
      // Call original handler and hold on to its return value.
      delegate = originalCompletionHandler(ad, error);
    }

    // Release reference to handler. Objects retained by the handler will also be released.
    originalCompletionHandler = nil;

    return delegate;
  };

  NSString *adUnit = adConfiguration.credentials.settings[@"parameter"];
  [[Applins shareSDK] initSDK:adUnit];
  [[Applins shareSDK] preloadInterstitialAd:adUnit delegate:self isTest:YES];
}

#pragma mark GADMediationInterstitialAd implementation

- (void)presentFromViewController:(UIViewController *)viewController {
    if ([[Applins shareSDK]  isInterstitialReady]) {
        [[Applins shareSDK]  showInterstitialAD];
    }
}


#pragma mark - Delegate

- (void)ALSLoadInterstitialSuccess {
    _adEventDelegate = _loadCompletionHandler(self, nil);
   
}

- (void)ALSAdView:(ALSADMRAIDView*)adView loadADFailedWithError:(NSError*)error {
    _adEventDelegate = _loadCompletionHandler(nil, error);
}

- (void)ALSAdViewShow:(ALSADMRAIDView*)adView {
    [_adEventDelegate willPresentFullScreenView];
    [_adEventDelegate reportImpression];
}

- (BOOL)ALSAdView:(ALSADMRAIDView*)adView shouldOpenURL:(NSURL*)url {
    [_adEventDelegate reportClick];
    return YES;
}


//did click close button
- (void)ALSAdViewCloseButtonPressed:(ALSADMRAIDView*)adView {
    [_adEventDelegate didDismissFullScreenView];
}

@end
