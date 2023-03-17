Releases
========

1.2
---
If user does not provide ad server details (`advertiserId`, `campaignId`, `creativeId` and `lineItemId`) as part of the `BoltiveTagDetails` struct - BoltiveSDK will try to obtain these from the `GADResponseInfo` object in the case of Google Mobile Ads SDK as a Primary SDK.  This is supported for both Banners and Interstitials.

The `BoltiveMonitor.captureInterstitial` API now requires an instance of `GADInterstitialAd` as a parameter.


1.1
---
Introduced `BoltiveTagDetails.appName` for tracking purposes.  If not provided the value is set to `Bundle.main.bundleIdentifier`.  


1.0
---
Initial release.
