//
//  MAXInterstitialViewController.swift
//  BoltiveDemo
//
//  Created by Olena Stepaniuk on 22.09.2022.
//

import UIKit
import AppLovinSDK
import Boltive

fileprivate let badInterstitialAdUnitId = "d8f44b2ed5155c0d"
fileprivate let okAdUnitId = "d487e5e79bc9bb5a"

class MAXInterstitialViewController: UIViewController, MAAdDelegate {
 
    let loadButton = UIButton()
    var interstitialAd: MAInterstitialAd!
    
    let monitor = BoltiveMonitor(configuration: BoltiveConfiguration(clientId: "adl-test",
                                                                     adUnitId: badInterstitialAdUnitId,
                                                                     adNetwork: .AppLovinMAX))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLoadButton()
    }
    
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
        interstitialAd = MAInterstitialAd(adUnitIdentifier: adUnitId)
        interstitialAd.delegate = self
        interstitialAd.load()
    }
    
    // MARK: - MAAdDelegate
    
    func didLoad(_ ad: MAAd) {
        if interstitialAd.isReady {
            interstitialAd.show()
        }
    }
    
    func didDisplay(_ ad: MAAd) {
        monitor.captureInterstitial { [weak self] in
            print("Ad was flagged.")
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self?.loadAd(with: okAdUnitId)
            }
        }
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {}
    
    func didHide(_ ad: MAAd) {}
    
    func didClick(_ ad: MAAd) {}
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {}
}
