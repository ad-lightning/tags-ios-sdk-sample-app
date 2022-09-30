//
//  TestCaseList.swift
//  BoltiveDemo
//
//  Created by Olena Stepaniuk on 13.09.2022.
//

import Foundation

class TestCaseList {
    
    static var testCases: [[String: [TestCase]]] {
        return [
            [
                "Google Ad Manager" : [
                    TestCase(title: "Banner", viewController: GAMBannerViewController()),
                    TestCase(title: "Interstitial", viewController: GAMInterstitialViewController())
                ]
            ],
            [
                "Applovin MAX" : [
                    TestCase(title: "Banner", viewController: MAXBannerViewController()),
                    TestCase(title: "Interstitial", viewController: MAXInterstitialViewController())
                ]
            ]
        ]
    }
}
