//
//  ViewController.swift
//  BoltiveDemo
//
//  Created by Olena Stepaniuk on 05.09.2022.
//

import UIKit
import GoogleMobileAds
import Boltive

fileprivate let gamAdUnitId = "/21808260008/boltive-banner-with-ok-and-bad-url"

class ViewController: UIViewController, GADBannerViewDelegate {
    
    var bannerView: GAMBannerView!
    
    let monitor = BoltiveMonitor(configuration: BoltiveConfiguration(clientId: "adl-test", adUnitId: gamAdUnitId))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Boltive v\(BoltiveMonitor.sdkVersion)"
       
        bannerView = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.adUnitID = gamAdUnitId
        
        addBannerViewToView(bannerView)
        
        bannerView.load(GADRequest())
    }
    
    func addBannerViewToView(_ bannerView: GAMBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        
        let constraints = [
            bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    
    // MARK: GADBannerViewDelegate
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        monitor.capture(bannerView: bannerView) { [weak self] view in
            self?.bannerView.removeFromSuperview()
        }
    }
}

