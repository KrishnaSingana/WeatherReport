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
    let connectionManagerInstance = ConnectionManager.sharedInstance
    
    fileprivate var citiesArray = [City]()
    fileprivate var selectedCity: City!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpSearchController()
        self.citiesTableView.isHidden = true
        
    }

    private func setUpSearchController() {
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.searchBar.delegate = self as UISearchBarDelegate
        searchController.searchBar.placeholder = "Search Cities (enter min 3 char to start search)"
        searchController.searchBar.searchTextField.font = UIFont.systemFont(ofSize: 14)
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
        return citiesArray.count
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
        cell?.accessoryType = .disclosureIndicator
        
        let city = citiesArray[indexPath.row]
        let cityName = city.areaName?[0].value ?? ""
        let country = city.country?[0].value ?? ""
        
        cell!.textLabel?.text = "\(cityName), \(country)"
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCity = citiesArray[indexPath.row]
        self.performSegue(withIdentifier: "searchCityViewToCityWeatherViewSegue", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchCityViewToCityWeatherViewSegue" {
            let cityWeatherVC = segue.destination as? CityWeatherViewController
            cityWeatherVC?.selectedCity = self.selectedCity
        }
    }

}

//MARK:- SerachBar Delegate Methods
extension CitySearchViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 2 {
            self.getListOfCitiesWith(searchText)
        } else {
            self.clearCitiesArray()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.clearCitiesArray()
    }
    
    fileprivate func clearCitiesArray() {
        DispatchQueue.main.async {
            self.citiesArray.removeAll()
            self.citiesTableView.reloadData()
        }
    }
}

// MARK: - UISearchResultsUpdating Delegate Method
extension CitySearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

extension CitySearchViewController {
        fileprivate func getListOfCitiesWith(_ searchText : String) {
            guard let apiRequest =  connectionManagerInstance.getCitySearchApiRequestWith(searchText) else {
                return
            }

            let defaultSession = URLSession(configuration: .default)
            
            let dataTask = defaultSession.dataTask(with: apiRequest)
            { data, response , error in
                if (response as? HTTPURLResponse)?.statusCode == 200 {
                    guard let citiesData = data else { return }
                    do {
                        let citiesList = try JSONDecoder().decode(SearchAPI.self, from: citiesData)
                        self.parseCitiesWith(citiesList)
                    } catch {
                        print("JSON Data Parsing Error : \(error)")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.searchController.searchBar.text = ""
                        Common.sharedCommonInstance.showAlertWith("", "City not found. Search for different city.",
                                                                  onScreen: self)
                    }
                }
            }
            dataTask.resume()
        }
    
    fileprivate func parseCitiesWith(_ resultData : SearchAPI) {
        citiesArray.removeAll()
        let count = resultData.searchApi?.citiesList?.count ?? 0
        for index in 0..<count   {
            let city = resultData.searchApi?.citiesList?[index]
            citiesArray.append(city!)
        }
        DispatchQueue.main.async {[unowned self] in
            self.citiesTableView.reloadData()
            if self.citiesArray.count > 0 {
                self.citiesTableView.isHidden = false
            }
        }
    }
}
