# Boltive iOS SDK

Boltive iOS SDK is a native iOS solution for intercepting malicious ad creatives.

**Quick facts:**

- The minimum supported iOS version is 14.0 (this requirement can be lowered if needed).

- SDK supports banner and interstitial ad formats. 

- SDK has been explicitly tested against GAM, AdMob, AppLovin MAX, however the SDK is not limited to these integration scenarios, see [this section](https://github.com/ad-lightning/ios-sdk-sample-app#other-ad-networks-and-sdks).

- Current SDK version is 0.4 (private beta).

## Integration

1. Download the [SDK zip archive](http://sdk.boltive.com.s3.amazonaws.com/ios/boltive-ios-sdk-0.4.2.zip) and unzip it: 
```
curl -O http://sdk.boltive.com.s3.amazonaws.com/ios/boltive-ios-sdk-0.4.2.zip
unzip boltive-ios-sdk-0.3.3.zip
```
2. Drag and drop the unzipped `boltive-ios-sdk.xcframework` into your Xcode project.
3. Go to your target settings. Make sure that on the `General` tab under `Frameworks and Libraries` `boltive-ios-sdk.xcframework` is marked as `Embed & Sign`. 

**Note:** Sample app project in this repo already contains a reference to the SDK in the project root, however you have to manually download and unzip the framework into the project root directory `BoltiveDemo`.

## User Guide

The code snippets below are based on Google Mobile Ads SDK, but would be similar for any other ad network SDK - as all follow a pretty much common patterns.

### Banner 

`BoltiveMonitor` object can be instantiated either in a view controller or a view model context - ideally the one designated as [GADBannerViewDelegate](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/api/reference/Protocols/GADBannerViewDelegate) - so that the lifetime of the `BoltiveMonitor` is tied to the lifetime of the delegate and that of the ad banner context.
Instantiate `BoltiveConfiguration` object and setup its properties: 
- `clientId`: unique client id provided by Boltive;
- `adNetwork`: the type of used ad network(the options are `GoogleAdManager`, `AdMob` and `AppLovinMAX` or you can specify custom ad network; default is `GoogleAdManager`);
- `adUnitId`: unique identifier for the ad unit;
- `advertiserId`: unique identifier for the advertiser;
- `campaignId`: unique identifier for the campaign;
- `creativeId`: unique identifier for the creative;
- `lineItemId`: unique identifier for the lineitem;
- `sspRefreshCode`: SSP refresh code. 

Pass `BoltiveConfiguration` object as `BoltiveMonitor` initialization parameter. 
```swift
let boltiveMonitor = BoltiveMonitor(configuration: BoltiveConfiguration(clientId: "<your client id>", adUnitId: "<your ad unit id>", adNetwork: .GoogleAdManager))
```

In the `GADBannerViewDelegate`'s `bannerViewDidReceiveAd(_ bannerView: GADBannerView)` method capture the `GADBannerView` object:

```swift
boltiveMonitor.capture(bannerView: bannerView) { bannerView in
    // handle banner view after the ad was flagged
}
```

The call of this closure signals that the rendered ad is flagged by `BoltiveMonitor`. **In the provided callback closure you should reload the banner and/or do any other side effects as needed, f.e. hide the banner or use a different ad unit.**

**Note**: Unlike web, on mobile `BoltiveMonitor` does not actually block or prevent **banner ads** (it is different for interstitials, they are dismissed automatically) from rendering - it only reports them and signals to the app native code.  **It is your responsibility as the app developer to take appropriate action in the callback closure**: i.e. to reload and refresh the banner, render a different ad unit, remove the banner alltogether etc.  The most common action to take would be to repeat banner loading by calling `bannerView.load(_ request: GADRequest?)` method.  

Also please note that every time the ad is flagged, SDK stops monitoring it, so **make sure you recapture the banner in every `bannerViewDidReceiveAd` delegate call**.

### Interstitial

`BoltiveMonitor` also supports capturing interstitial ads with a different API: `BoltiveMonitor.captureInterstitial`.  Just like for banners `BoltiveMonitor` object should be instantiated first either in a view controller or a view model object context - the one which manages interstitial presentation.

Add a call of `BoltiveMonitor.captureInterstitial` method right after presenting the interstitial ad: f.e. after calling `GADInterstitialAd.present(fromRootViewController: UIViewController)`.

```swift
monitor.captureInterstitial { [weak self] in
    // do any side effect here, f.e. load another interstitial ad
}
```

**Note**: Unlike banner ads, `Boltive SDK` actually blocks and dismisses a flagged interstitial ad right away.  You can load a new interstitial in the provided `adBlocked` callback closure or perform any additional side effects in it.

## Other Ad Networks and SDKs

`Boltive SDK` was tested against GAM and Google Mobile Ads SDK integration.  However `BoltiveMonitor` API is designed to be SDK-agnostic.  The only assumption it makes is that the ad is rendered in the `WKWebView` object contained somewhere within a `UIView`-based banner view hierarchy.  Most ad SDKs provide callback mechanisms similar to a `GADBannerViewDelegate`'s' `bannerViewDidReceiveAd` method in which you can use `BoltiveMonitor` to capture the banner - as described above for the GAM scenario.

## Google Ad Manager and AdMob

Google Ad Manager and AdMob scenarios assume the integration of Google Mobile Ads SDK into the app.

- [Google Mobile Ads SDK for GAM](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/quick-start)
- [Google Mobile Ads SDK for AdMob](https://developers.google.com/admob/ios/quick-start)

## AppLovin MAX 

AppLovin MAX assumes integration of AppLovin MAX SDK into the app.

- [AppLovin MAX SDK Integration](https://dash.applovin.com/documentation/mediation/ios/getting-started/integration)

## BoltiveDemo App 

To get started with the demo app, follow these steps:

1. Follow instructions from the [Integration](https://github.com/ad-lightning/android-sdk-sample-app#integration) section. 
2. Update Swift Package Manager caches (File > Packages > Reset Package Caches). 

**Note**: Most examples work on Simulator, but `Applovin MAX` examples work on device only. To run the app on your device - choose your team id on `Signing & Capabilities` tab.
