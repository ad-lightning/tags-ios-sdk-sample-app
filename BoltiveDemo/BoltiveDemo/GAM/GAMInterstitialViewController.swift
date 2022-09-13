//
//  GAMInterstitialViewController.swift
//  BoltiveDemo
//
//  Created by Olena Stepaniuk on 13.09.2022.
//

import UIKit
import GoogleMobileAds
import Boltive

fileprivate let badInterstitialAdUnitId = "/21808260008/boltive-interstial-with-bad-url"
fileprivate let testAdUnitId = "ca-app-pub-3940256099942544/4411468910"

class GAMInterstitialViewController: UIViewController {
    
    let loadButton =  UIButton()
    var interstitial: GADInterstitialAd?
    
    let monitor = BoltiveMonitor(configuration: BoltiveConfiguration(clientId: "adl-test",
                                                                     adUnitId: badInterstitialAdUnitId))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLoadButton()
    }
    
    // MARK: - Helpers
    
    private func setupLoadButton() {
        view.addSubview(loadButton)
        loadButton.translatesAutoresizingMaskIntoConstraints = false
        loadButton.setTitleColor(.blue, for: .normal)
        loadButton.setTitle("loadAd", for: .normal)
        loadButton.addTarget(self, action: #selector(loadAdTapped), for: .touchUpInside)
        
        let constraints = [
            loadButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            loadButton.widthAnchor.constraint(equalToConstant: 100),
            loadButton.heightAnchor.constraint(equalToConstant: 50),
            loadButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func loadAdTapped() {
        loadAd(with: badInterstitialAdUnitId)
    }
    
    private func loadAd(with adUnitId: String) {
        GADInterstitialAd.load(withAdUnitID: adUnitId, request: GAMRequest()) { [weak self] ad, _ in
            guard let self = self else { return }
            if ad != nil {
                self.interstitial = ad
                self.interstitial?.present(fromRootViewController: self)
                self.monitor.captureInterstitial { [weak self] in
                    // load another ad
                    self?.loadAd(with: testAdUnitId)
                }
            }
        }
    }
}
