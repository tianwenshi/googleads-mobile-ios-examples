//
//  GADMBannerApplins.h
//  GPADMOB
//
//  Created by 兰旭平 on 2017/11/15.
//  Copyright © 2017年 MySDK.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@import GoogleMobileAds;
@interface GADMBannerApplins : NSObject
- (void)loadBannerForAdConfiguration:(GADMediationBannerAdConfiguration *)adConfiguration
                   completionHandler:(GADMediationBannerLoadCompletionHandler)completionHandler;
@end
