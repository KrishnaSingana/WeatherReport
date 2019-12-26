//
//  CitySearchViewController.swift
//  WeatherReport
//
//  Created by Krishna Singana on 23/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import UIKit

let kCitiesUserDefaultsKey = "CitiesArrayKey"

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
    }

    override func viewWillAppear(_ animated: Bool) {
        self.searchController.isActive = false
        self.updateTableViewWithUserDefaultsCitiesData()
    }

    private func setUpSearchController() {
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.searchBar.delegate = self as UISearchBarDelegate
        searchController.searchBar.placeholder = "Search Cities (enter min 3 char to start search)"
        searchController.searchBar.searchTextField.font = UIFont.systemFont(ofSize: 14)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.accessibilityIdentifier = "CitySearchBar"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    internal func appendNewCityToUserDefaultsArrayWith(city: City) {
        var citiesDataArray = UserDefaults.standard.array(forKey: kCitiesUserDefaultsKey) as? [Data]
        if citiesDataArray == nil {
            let array: [Data] = []
            citiesDataArray = array
            UserDefaults.standard.setValue(citiesDataArray, forKey: kCitiesUserDefaultsKey)
        }

        let defaults = UserDefaults.standard
        let data = try? PropertyListEncoder().encode(city)
        guard let cityData = data else { return }

        let result = self.validateCityIsInUserDefaultsArrayWith(cityObj: city)
        if result.1, let cityIndex = result.0 {
            citiesDataArray?.remove(at: cityIndex)
        }
        if let count = citiesDataArray?.count, count >= 10 {
            _ = citiesDataArray?.remove(at: 0)
        }
        citiesDataArray?.append(cityData)
        defaults.setValue(citiesDataArray, forKey: kCitiesUserDefaultsKey)
    }

    internal func validateCityIsInUserDefaultsArrayWith(cityObj: City) -> ( Int?, Bool) {
        let defaults = UserDefaults.standard
        let citiesDataArray = defaults.array(forKey: kCitiesUserDefaultsKey) as? [Data]
        guard let count = citiesDataArray?.count else { return (nil, false) }
        for index in 0..<count {
            let data = citiesDataArray?[index]
            guard let cityData = data else { return (nil, false) }
            // Use PropertyListDecoder to convert Data into Player
            guard let city = try? PropertyListDecoder().decode(City.self, from: cityData) else {
                return (nil, false)
            }
            if cityObj.latitude == city.latitude && cityObj.longitude == city.longitude {
                return (index, true)
            }
        }
        return (nil, false)
    }

    internal func retriveCitiesDataFromUserDefaults() -> [City] {
        var citiesArray = [City]()
        let defaults = UserDefaults.standard
        var citiesDataArray = defaults.array(forKey: kCitiesUserDefaultsKey) as? [Data]
        if citiesDataArray == nil {
            let array: [Data] = []
            citiesDataArray = array
            defaults.setValue(citiesDataArray, forKey: kCitiesUserDefaultsKey)
        }
        guard let count = citiesDataArray?.count else { return citiesArray }
        for index in 0..<count {
            let data = citiesDataArray?[index]
            guard let cityData = data else { return citiesArray }
            // Use PropertyListDecoder to convert Data into Player
            guard let city = try? PropertyListDecoder().decode(City.self, from: cityData) else {
                return citiesArray
            }
            citiesArray.append(city)
        }
        return citiesArray
    }

    private func updateTableViewWithUserDefaultsCitiesData() {
        self.citiesArray = self.retriveCitiesDataFromUserDefaults().reversed()
        DispatchQueue.main.async {
            if self.citiesArray.count > 0 {
                self.citiesTableView.reloadData()
            }
        }
    }
}

// MARK: - TableView Delegate & DataSource Methods
extension CitySearchViewController: UITableViewDataSource, UITableViewDelegate {

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
        self.appendNewCityToUserDefaultsArrayWith(city: selectedCity)
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

// MARK: - SerachBar Delegate Methods
extension CitySearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 2 {
            self.getListOfCitiesWith(searchText)
        } else {
            self.clearCitiesArray()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.updateTableViewWithUserDefaultsCitiesData()
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
    fileprivate func getListOfCitiesWith(_ searchText: String) {
        guard let apiRequest =  connectionManagerInstance.getCitySearchApiRequestWith(searchText) else {
            return
        }

        let defaultSession = URLSession(configuration: .default)

        let dataTask = defaultSession.dataTask(with: apiRequest) { data, response, error in
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                guard let citiesData = data else { return }
                do {
                    let citiesList = try JSONDecoder().decode(SearchAPI.self, from: citiesData)
                    self.citiesArray.removeAll()
                    self.citiesArray = self.parseCitiesWith(citiesList)
                    DispatchQueue.main.async {[unowned self] in
                        self.citiesTableView.reloadData()
                    }
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

    internal func parseCitiesWith(_ resultData: SearchAPI) -> [City] {
        var array = [City]()
        let count = resultData.searchApi?.citiesList?.count ?? 0
        for index in 0..<count {
            if let city = resultData.searchApi?.citiesList?[index] {
                array.append(city)
            }
        }
        return array
    }
}
