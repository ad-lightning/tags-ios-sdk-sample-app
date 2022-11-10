//
//  MAXBannerViewController.swift
//  BoltiveDemo
//
//  Created by Olena Stepaniuk on 22.09.2022.
//

import Foundation
import AppLovinSDK
import Boltive

fileprivate let bannerAdUnitId = "43629f686a8fef7f"

class MAXBannerViewController: UIViewController, MAAdViewAdDelegate {

    var bannerView: MAAdView!

    let loadButton = UIButton()
    
    let monitor = BoltiveMonitor(configuration: BoltiveConfiguration(clientId: "adl-test", adNetwork: .AppLovin))
    
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
        bannerView = MAAdView(adUnitIdentifier: bannerAdUnitId)
        bannerView.delegate = self
        bannerView.frame = CGRect(origin: .zero, size: CGSize(width: 320, height: 50))
        bannerView.backgroundColor = .white
    }
    
    private func addBannerViewToView(_ bannerView: UIView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        
        let constraints = [
            bannerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bannerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            bannerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func loadAd() {
        bannerView?.removeFromSuperview()
        setupBannerView()
        bannerView.loadAd()
    }
    
    // MARK: - MAAdViewAdDelegate
    
    func didLoad(_ ad: MAAd) {
        addBannerViewToView(bannerView)
        monitor.capture(bannerView: bannerView, tagDetails: BoltiveTagDetails(adUnitId: bannerAdUnitId)) { bannerView in
            bannerView.removeFromSuperview()
        }
    }
    
    func didExpand(_ ad: MAAd) {}
    
    func didCollapse(_ ad: MAAd) {}
        
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {}
    
    func didDisplay(_ ad: MAAd) {}
    
    func didHide(_ ad: MAAd) {}
    
    func didClick(_ ad: MAAd) {}
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {}
}
