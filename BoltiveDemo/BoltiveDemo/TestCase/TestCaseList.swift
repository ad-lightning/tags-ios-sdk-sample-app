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
                    TestCase(title: "Banner", viewController: GAMBannerViewController())
                ]
            ]
        ]
    }
    
    static var gamTestCases: [TestCase] {
        
        return [
            TestCase(title: "GAM Banner", viewController: GAMBannerViewController())
        ]
    }
}
