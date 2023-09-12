//
//  GADMBannerApplins.m
//  GPADMOB
//
//  Created by 兰旭平 on 2017/11/15.
//  Copyright © 2017年 MySDK.com. All rights reserved.
//

#import "GADMBannerApplins.h"
#import <ApplinsSDK/ApplinsSDK.h>
#include <stdatomic.h>

@interface GADMBannerApplins () <GADMediationAdapter, ALSAdViewDelegate, GADMediationBannerAd> {
  /// The sample banner ad.
  ALSADMRAIDView *_bannerAd;

  /// The completion handler to call when the ad loading succeeds or fails.
  GADMediationBannerLoadCompletionHandler _loadCompletionHandler;

  /// The ad event delegate to forward ad rendering events to the Google Mobile Ads SDK.
  id<GADMediationBannerAdEventDelegate> _adEventDelegate;
}
@end

@implementation GADMBannerApplins

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

- (void)loadBannerForAdConfiguration:(GADMediationBannerAdConfiguration *)adConfiguration
                   completionHandler:(GADMediationBannerLoadCompletionHandler)completionHandler{
    __block atomic_flag completionHandlerCalled = ATOMIC_FLAG_INIT;
    __block GADMediationBannerLoadCompletionHandler originalCompletionHandler =
        [completionHandler copy];

    _loadCompletionHandler = ^id<GADMediationBannerAdEventDelegate>(
        _Nullable id<GADMediationBannerAd> ad, NSError *_Nullable error) {
      // Only allow completion handler to be called once.
      if (atomic_flag_test_and_set(&completionHandlerCalled)) {
        return nil;
      }

      id<GADMediationBannerAdEventDelegate> delegate = nil;
      if (originalCompletionHandler) {
        // Call original handler and hold on to its return value.
        delegate = originalCompletionHandler(ad, error);
      }

      // Release reference to handler. Objects retained by the handler will also be released.
      originalCompletionHandler = nil;

      return delegate;
    };
    NSString *adUnit = adConfiguration.credentials.settings[@"parameter"];
    ALSBannerSize ctSize;
    if (adConfiguration.adSize.size.height == 100) {
        ctSize = ALSBannerSizeW320H100;
    } else if (adConfiguration.adSize.size.height == 250) {
        ctSize = ALSBannerSizeW300H250;
    } else {
        ctSize = ALSBannerSizeW320H50;
    }
    [[Applins shareSDK] initSDK:adUnit];
    [[Applins shareSDK] getBannerAD:adUnit delegate:self adSize:ctSize isTest:NO];
    
}

#pragma mark GADMediationBannerAd implementation

- (nonnull UIView *)view {
  return _bannerAd;
}

//banner ad
- (void)ALSLoadBannerSuccess:(ALSADMRAIDView*)adView {
    _bannerAd = adView;
    _adEventDelegate = _loadCompletionHandler(self, nil);
}

//error while request ads.
- (void)ALSAdView:(ALSADMRAIDView*)adView loadADFailedWithError:(NSError*)error {
    _adEventDelegate = _loadCompletionHandler(nil, error);
}

//banner ad clicked
- (void)ALSAdViewClicked:(ALSADMRAIDView*)adView{
    [_adEventDelegate reportClick];
}
 

- (void)ALSAdViewShow:(ALSADMRAIDView*)adView {
    [_adEventDelegate reportImpression];
}

@end

