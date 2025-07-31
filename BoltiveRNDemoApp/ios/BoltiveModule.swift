//
//  BoltiveModule.swift
//  BoltiveRNDemoApp
//
//  Created by Olena Stepaniuk on 23.06.2025.
//

import React
import Foundation
import UIKit
import Boltive

@objc(BoltiveModule)
class BoltiveModule: NSObject {
  
  private var boltiveMonitor: BoltiveMonitor?
  
  @objc
  static func requiresMainQueueSetup() -> Bool {
    return true
  }
  
  @objc
  func initialize(
    _ clientId: String,
    adNetwork: String,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    DispatchQueue.main.async {
      let network = self.mapAdNetwork(adNetwork)
      let configuration = BoltiveConfiguration(clientId: clientId, adNetwork: network)
      self.boltiveMonitor = BoltiveMonitor(configuration: configuration)
      resolver("INITIALIZED")
    }
  }
  
  @objc
  func captureBanner(
    _ reactTag: NSNumber,
    tagDetails: NSDictionary,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    DispatchQueue.main.async {
      guard let boltiveMonitor = self.boltiveMonitor else {
        rejecter("NOT_INITIALIZED", "Boltive SDK not initialized", nil)
        return
      }
      
      guard let bridge = RCTBridge.current(),
            let uiManager = bridge.uiManager,
            let view = uiManager.view(forReactTag: reactTag) else {
        rejecter("VIEW_NOT_FOUND", "View not found for reactTag", nil)
        return
      }
      
      let boltiveTagDetails = self.createTagDetails(from: tagDetails)
      
      boltiveMonitor.capture(bannerView: view, tagDetails: boltiveTagDetails) { blockedView in
        // Return analysis results instead of blocking directly
        DispatchQueue.main.async {
          let result: [String: Any] = [
            "status": "analyzed",
            "shouldBlock": true,
            "reason": "Malicious ad detected by Boltive iOS SDK",
            "reactTag": reactTag.intValue,
            "adUnitId": boltiveTagDetails.adUnitId ?? ""
          ]
          resolver(result)
        }
      }
    }
  }
  
  // MARK: - Helper Methods
  
  private func mapAdNetwork(_ networkString: String) -> BoltiveAdNetwork {
    switch networkString.lowercased() {
    case "googleadmanager":
      return .GoogleAdManager
    case "applovin":
      return .AppLovin
    case "admob":
      return .AdMob
    default:
      return .customAdNetwork(adNetworkName: networkString)
    }
  }
  
  private func createTagDetails(from dictionary: NSDictionary) -> BoltiveTagDetails {
    return BoltiveTagDetails(
      adUnitId: dictionary["adUnitId"] as? String,
      advertiserId: dictionary["advertiserId"] as? String,
      campaignId: dictionary["campaignId"] as? String,
      creativeId: dictionary["creativeId"] as? String,
      lineItemId: dictionary["lineItemId"] as? String,
      sspRefreshCode: dictionary["sspRefreshCode"] as? String,
      appName: dictionary["appName"] as? String
    )
  }
}
