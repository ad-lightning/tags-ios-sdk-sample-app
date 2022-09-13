//
//  TestCaseListViewController.swift
//  BoltiveDemo
//
//  Created by Olena Stepaniuk on 13.09.2022.
//

import UIKit
import Boltive

fileprivate let cellId = "TestCaseListCell"

class TestCaseListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupTableView()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TestCaseList.testCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return TestCaseList.testCases[section].first?.key
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TestCaseList.testCases[section].first?.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let testCase = TestCaseList.testCases[indexPath.section].first?.value[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = testCase?.title
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let sectionTestCases = TestCaseList.testCases[indexPath.section].first else { return }
        let testCase = sectionTestCases.value[indexPath.row]
        
        testCase.viewController.title = "\(sectionTestCases.key) \(testCase.title)"
        
        navigationController?.pushViewController(testCase.viewController, animated: true)
    }
    
    // MARK: - Helpers
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        title = "Boltive v\(BoltiveMonitor.sdkVersion)"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        NSLayoutConstraint.activate( [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
    }
}
