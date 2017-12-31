//
//  SearchController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import KRProgressHUD

class SearchController: UITableViewController {
    var filteredCoinNames = [[String]]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCoinNames.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    var chartController: ChartController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchController.isActive = false
        self.dismiss(animated: true) {
            
            let coinName = self.filteredCoinNames[indexPath.row][1]
            
            self.chartController?.goingToChartDetailControllerFromSearch(coinName: coinName)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        cell.textLabel?.text = filteredCoinNames[indexPath.row][0]
        cell.detailTextLabel?.text = filteredCoinNames[indexPath.row][1]
        
        
        return cell
    }

}

//MARK: handle search 
extension SearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            
            filteredCoinNames = Global.coinsArray.filter {
                team in return (team[1].lowercased().contains(searchText.lowercased()))
            }
        } else {
            
            filteredCoinNames = Global.coinsArray
        }
        
        tableView.reloadData()
    }
}

//MARK: handle dismiss controller

extension SearchController {
    
    func dismissController() {
        self.searchController.isActive = false
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: setup Background

extension SearchController {
    
    fileprivate func setupViews() {
        setupBackground()
        setupNavBar()
        setupTableView()
        
    }
    
    private func setupTableView() {
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
//        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "Search"
        navigationItem.titleView = searchController.searchBar
    }
    
    fileprivate func setupBackground() {
        
        view.backgroundColor = .white
    }
    
    fileprivate func setupNavBar() {
        
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = true
        
        self.title = "Search"
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let image = UIImage(named: AssetName.close.rawValue)?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(dismissController))
        
        navigationController?.navigationBar.barTintColor = StyleGuideManager.crytpTweetsBarTintColor
    }
}

