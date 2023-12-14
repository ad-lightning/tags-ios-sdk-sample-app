# Boltive iOS SDK

Boltive iOS SDK is a native iOS solution for intercepting malicious ad creatives.

**Quick facts:**

- The minimum supported iOS version is 12.0 (this requirement can be lowered if needed).

- SDK supports banner and interstitial ad formats. 

- SDK has been explicitly tested against GAM, AdMob, AppLovin MAX, however the SDK is not limited to these integration scenarios, see [this section](https://github.com/ad-lightning/ios-sdk-sample-app#other-ad-networks-and-sdks).

- Current SDK version is 1.3.  See [release notes](CHANGELOG.md).

## Integration

### Cocoapods
1. In case there were no pods previously in your project, run
```sh
pod init
```
to create the Podfile and supporting workspace.  

2. Add `Boltive` pod to your `Podfile`: 
```ruby
target 'MyApp' do 
    pod 'Boltive'
end
```
3. Save the Podfile and run:
```sh
pod install
``` 

4. From now on use the workspace (i.e. `MyApp.xcworkspace`) to open the project.

### Manual integration

1. Download the [SDK zip archive](https://d29z9h4vafd34g.cloudfront.net/ios/boltive-ios-sdk-1.3.11.zip) and unzip it:
```sh
curl -O https://d29z9h4vafd34g.cloudfront.net/ios/boltive-ios-sdk-1.3.11.zip
unzip boltive-ios-sdk-1.3.11.zip
```
2. Drag and drop the unzipped `Boltive.xcframework` into your Xcode project.
3. Go to your target settings. Make sure that on the `General` tab under `Frameworks and Libraries` `Boltive.xcframework` is marked as `Embed & Sign`. 

**Note:** Sample app project in this repo already contains a reference to the SDK in the project root, however you have to manually download and unzip the framework into the project root directory `BoltiveDemo`.

## User Guide

The code snippets below are based on Google Mobile Ads SDK, but would be similar for any other ad network SDK - as all follow a pretty much common patterns.

### Banner 

`BoltiveMonitor` object can be instantiated either in a view controller or a view model context - ideally the one designated as [GADBannerViewDelegate](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/api/reference/Protocols/GADBannerViewDelegate) - so that the lifetime of the `BoltiveMonitor` is tied to the lifetime of the delegate and that of the ad banner context.
Instantiate `BoltiveConfiguration` object and setup its properties: 
- `clientId`: unique client id provided by Boltive;
- `adNetwork`: the type of used ad network(the options are `GoogleAdManager`, `AdMob` and `AppLovinMAX` or you can specify custom ad network; default is `GoogleAdManager`);

Pass `BoltiveConfiguration` object as `BoltiveMonitor` initialization parameter. 
```swift
let boltiveMonitor = BoltiveMonitor(configuration: BoltiveConfiguration(clientId: "<your client id>", adUnitId: "<your ad unit id>", adNetwork: .GoogleAdManager))
```

In the `GADBannerViewDelegate`'s `bannerViewDidReceiveAd(_ bannerView: GADBannerView)` method capture the `GADBannerView` object. For tracking purposes please provide `BoltiveTagDetails` object with these optional properties: 
- `adUnitId`: unique identifier for the ad unit;
- `advertiserId`: unique identifier for the advertiser;
- `campaignId`: unique identifier for the campaign;
- `creativeId`: unique identifier for the creative;
- `lineItemId`: unique identifier for the lineitem;
- `sspRefreshCode`: SSP refresh code;
- `appName`: name of the app(default value is `Bundle.main.bundleIdentifier`).

If ad server details (`advertiserId`, `campaignId`, `creativeId` and `lineItemId`) are not provided - BoltiveSDK will try to obtain them from the `GADResponseInfo` object in the case of Google Mobile Ads SDK as a Primary SDK.

```swift
let tagDetails = BoltiveTagDetails(adUnitId: <ad unit id>, advertiserId: <advertiser id>, campaignId: <campaign id>,
                creativeId: <creative id>, lineItemId: <lineitem id>, sspRefreshCode: <SSP refresh code>, appName: <app name>)
boltiveMonitor.capture(bannerView: bannerView, tagDetails: tagDetails) { bannerView in
    // handle banner view after the ad was flagged
}
```

The call of this closure signals that the rendered ad is flagged by `BoltiveMonitor`. **In the provided callback closure you should reload the banner and/or do any other side effects as needed, f.e. hide the banner or use a different ad unit.**

**Note**: `BoltiveMonitor` blocker will prevent the malicious ad creative from rendering - so the ad would become blank, 
however it will not automatically remove the native banner view from the screen (so worst case the user will see a blank ad).  
It will send a signal to the app native code (via the callback mechanism). 
**Then it is the responsibility of the app developer to take the appropriate action in the callback implementation**: f.e. reload and refresh the
banner, render a different ad unit, remove the banner altogether etc. The most common action to
take would be to call the native method that would reload the by calling `bannerView.load(_ request: GADRequest?)` method.

Also please note that every time the ad is flagged, SDK stops monitoring it, so **make sure you recapture the banner in every `bannerViewDidReceiveAd` delegate call**.

### Interstitial

`BoltiveMonitor` also supports capturing interstitial ads with a different API: `BoltiveMonitor.captureInterstitial`.  Just like for banners `BoltiveMonitor` object should be instantiated first either in a view controller or a view model object context - the one which manages interstitial presentation.

Add a call of `BoltiveMonitor.captureInterstitial` method right after presenting the interstitial ad: f.e. after calling `GADInterstitialAd.present(fromRootViewController: UIViewController)`. You should pass ad object, that you receive after loading ad(f.e. `GADInterstitialAd`). If there is no such object, you can pass `nil`. You should also provide `BoltiveTagDetails` object described in banner section.

```swift
let tagDetails = BoltiveTagDetails(adUnitId: <ad unit id>, advertiserId: <advertiser id>, campaignId: <campaign id>,
                creativeId: <creative id>, lineItemId: <lineitem id>, sspRefreshCode: <SSP refresh code>)
monitor.captureInterstitial(adObject: adObject, tagDetails: tagDetails) { [weak self] in
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

1. Follow instructions from the [Cocoapods Integration](https://github.com/ad-lightning/ios-sdk-sample-app#cocoapods) section. 
2. Open `BoltiveDemo.xcworkspace`
3. Update Swift Package Manager caches (File > Packages > Reset Package Caches). 

**Note**: Most examples work on Simulator, but `Applovin MAX` examples work on device only. To run the app on your device - choose your team id on `Signing & Capabilities` tab.
