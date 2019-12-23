//
//  CitySearchViewController.swift
//  WeatherReport
//
//  Created by Krishna Singana on 23/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import UIKit

class CitySearchViewController: UIViewController {

    @IBOutlet weak var citiesTableView: UITableView!
    
    // This is used for searching for particular healthCenter from the list.
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpSearchController()
    }

    private func setUpSearchController() {
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.searchBar.delegate = self as UISearchBarDelegate
        searchController.searchBar.placeholder = "Search Cities"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

}

//MARK:- TableView Delegate & DataSource Methods
extension CitySearchViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")

        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        }

        cell!.textLabel?.text = "Bangalore"
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected")
    }
}

//MARK:- SerachBar Delegate Methods
extension CitySearchViewController : UISearchBarDelegate {
    // Called when keyboard search button pressed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

    }
}

// MARK: - UISearchResultsUpdating Delegate Method
extension CitySearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

