//
//  GADMInterstitialApplins.h
//  GPADMOB
//
//  Created by 兰旭平 on 2017/11/14.
//  Copyright © 2017年 MySDK.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface GADMInterstitialApplins : NSObject
- (void)loadInterstitialForAdConfiguration:
            (GADMediationInterstitialAdConfiguration *)adConfiguration
                         completionHandler:
                             (GADMediationInterstitialLoadCompletionHandler)completionHandler;
@end
