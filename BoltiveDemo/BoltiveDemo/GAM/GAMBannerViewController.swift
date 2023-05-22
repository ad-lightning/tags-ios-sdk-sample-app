//
//  ViewController.swift
//  BoltiveDemo
//
//  Created by Olena Stepaniuk on 05.09.2022.
//

import UIKit
import GoogleMobileAds
import Boltive

fileprivate let bannerAdUnitId = "/21808260008/btest_banner_random"

class GAMBannerViewController: UIViewController, GADBannerViewDelegate {
    
    var bannerView: GAMBannerView!
    
    let loadButton = UIButton()
    
    let monitor = BoltiveMonitor(configuration: BoltiveConfiguration(clientId: "adl-test"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLoadButton()
        setupBannerView()
    }
    
    // MARK: GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        addBannerViewToView(bannerView)
        monitor.capture(bannerView: bannerView, tagDetails: BoltiveTagDetails(adUnitId: bannerAdUnitId)) { [weak self] view in
            self?.bannerView?.removeFromSuperview()
        }
    }
    
    // MARK: - Helpers
    
    private func setupLoadButton() {
        view.addSubview(loadButton)
        loadButton.translatesAutoresizingMaskIntoConstraints = false
        loadButton.setTitleColor(.blue, for: .normal)
        loadButton.setTitle("loadAd", for: .normal)
        loadButton.addTarget(self, action: #selector(loadAd), for: .touchUpInside)
        
        let constraints = [
            loadButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            loadButton.widthAnchor.constraint(equalToConstant: 100),
            loadButton.heightAnchor.constraint(equalToConstant: 50),
            loadButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupBannerView() {
        bannerView = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.adUnitID = bannerAdUnitId
    }
    
    private func addBannerViewToView(_ bannerView: UIView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        
        let constraints = [
            bannerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            bannerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func loadAd() {
        bannerView?.removeFromSuperview()
        bannerView.load(GADRequest())
    }
}
