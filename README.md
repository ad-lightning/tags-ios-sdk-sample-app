# Boltive iOS SDK

Boltive iOS SDK is a native iOS solution for intercepting malicious ad creatives in mobile banner ads.  

**Quick facts:**

- The minimum supported iOS version is 14.0.  

- SDK supports banner ad format. 

- We assume that the app integrates Google Mobile Ads SDK and works with Google Ad Manager, however the SDK is not limited by this assumption, see [this section](https://github.com/ad-lightning/android-sdk-sample-app#other-ad-networks-and-sdks).

- Current SDK version is 0.1 (private beta).

# User guide

## Integration

1. Download and unzip the SDK framework. 
2. Drag and drop `boltive-ios-sdk.xcframework` into your Xcode project.

**Note:** Sample app project in this repo already contains a reference to the SDK in the project root, however you have to manually download and unzip the framework into the project root directory `BoltiveDemo`.

## API

`BoltiveMonitor` object can be instantiated either in a view controller or a view model object context - ideally the one designated as [GADBannerViewDelegate](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/api/reference/Protocols/GADBannerViewDelegate) - so that the lifetime of the `BoltiveMonitor` is tied to the lifetime of the delegate and that of the ad banner context. Pass `clientId` and `adUnitId`(for GAM ad unit) as params.

```swift
let boltiveMonitor = BoltiveMonitor(configuration: BoltiveConfiguration(clientId: "<your client id>", adUnitId: "<your ad unit id>"))
```

In the `GADBannerViewDelegate`'s `bannerViewDidReceiveAd(_ bannerView: GADBannerView)` method capture the `GADBannerView` object:

```swift
boltiveMonitor.capture(bannerView: bannerView) { bannerView in
    // handle banner view after the ad was flagged
}
```

In the provided callback closure you can do any side effects. The call of this closure signals that the rendered ad is flagged by `BoltiveMonitor`. Take a note that every time the ad is flagged, SDK stops monitoring it, so make sure you recapture the banner in every `bannerViewDidReceiveAd` delegate call.

**Note**: Unlike web, on mobile `BoltiveMonitor` does not actually block or prevent any ads from rendering - it only reports them and signals to the app native code.  It is your responsibility as the app developer to take appropriate action in the callback closure: i.e. to reload and refresh the banner, render a different ad unit, remove the banner alltogether etc.  The most common action to take would be to repeat banner loading by calling `bannerView.load(_ request: GADRequest?)` method.  

## Other Ad Networks and SDKs

`Boltive SDK` was tested against GAM and Google Mobile Ads SDK integration.  However `BoltiveMonitor` API is designed to be SDK-agnostic.  The only assumption it makes is that the ad is rendered in the `WKWebView` object contained somewhere within a `UIView`-based banner view hierarchy.  Most ad SDKs provide callback mechanisms similar to a `GADBannerViewDelegate`'s' `bannerViewDidReceiveAd` method in which you can use `BoltiveMonitor` to capture the banner - as described above for the GAM scenario.

## Google Ad Manager

Google Ad Manager assumes integration of Google Mobile Ads SDK into the app.

References: 

- [GMA SDK Get Started](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/quick-start)
- [Banner Ads](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/banner)

