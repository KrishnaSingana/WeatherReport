//
//  WeatherReportTests.swift
//  WeatherReportTests
//
//  Created by Krishna Singana on 23/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import XCTest
@testable import WeatherReport

class WeatherReportTests: XCTestCase {

    var citiesArray = [City]()
    
    var citySearchVC : CitySearchViewController!

    override func setUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchVC: CitySearchViewController = storyboard.instantiateViewController(withIdentifier:
            String(describing: CitySearchViewController.self)) as! CitySearchViewController
        citySearchVC = searchVC

        //Clearing any cities data stored in UserDefaults
        UserDefaults.standard.setValue([Data](), forKey: kCitiesUserDefaultsKey)
        self.parseCitiesData()  //  Getting Cities list from json file
    }

    override func tearDown() {
        //Clearing any cities data stored in UserDefaults
        UserDefaults.standard.setValue([Data](), forKey: kCitiesUserDefaultsKey)
        self.citiesArray.removeAll()
    }

    func testAddingCityToUserDefaults() {
        let cityObj = self.citiesArray[0]
        //Getting Array of citiesData from UserDefaults
        let citiesDataArray = UserDefaults.standard.array(forKey: kCitiesUserDefaultsKey) as? [Data]
        XCTAssertEqual(citiesDataArray?.count, 0)   //  As we cleared data in UserDefaults, count should be 0
        citySearchVC.appendNewCityToUserDefaultsArrayWith(city: cityObj)  //  Appending new city object to UserDefaults
        let citiesDataArray2 = UserDefaults.standard.array(forKey: kCitiesUserDefaultsKey) as? [Data]
        XCTAssertEqual(citiesDataArray2?.count, 1)   // We added only one city to UserDefaults
    }

    func testCheckCityIsAlreadyPresentInUserDefaultsArray_CityNotPresentCase() {
        let cityObj = self.citiesArray[0]
        //Getting Array of citiesData from UserDefaults
        let citiesDataArray = UserDefaults.standard.array(forKey: kCitiesUserDefaultsKey) as? [Data]
        XCTAssertEqual(citiesDataArray?.count, 0)   //  As we cleared data in UserDefaults, count should be 0
       
        let result = citySearchVC.validateCityIsInUserDefaultsArrayWith(cityObj: cityObj)
        XCTAssertFalse(result.1)    //  As we don't have this object in UserDefaults, it will return false
    }
    
    func testCheckCityIsAlreadyPresentInUserDefaultsArray_CityPresentCase() {
        let cityObj = self.citiesArray[0]
        //Getting Array of citiesData from UserDefaults
        let citiesDataArray = UserDefaults.standard.array(forKey: kCitiesUserDefaultsKey) as? [Data]
        XCTAssertEqual(citiesDataArray?.count, 0)   //  As we cleared data in UserDefaults, count should be 0
       
        let result = citySearchVC.validateCityIsInUserDefaultsArrayWith(cityObj: cityObj)
        XCTAssertFalse(result.1)    //  As we don't have this city in UserDefaults, it will return false
        citySearchVC.appendNewCityToUserDefaultsArrayWith(city: cityObj)  //Appending cityObj to UserDefaults as it is not there
        //Will try to add same city again
        let result2 = citySearchVC.validateCityIsInUserDefaultsArrayWith(cityObj: cityObj)
        XCTAssertTrue(result2.1)    //  As this city is already present in UserDefaults, it will return true
    }

    func testRetrivingCitiesListFromUserDefaults() {
        //Getting Array of citiesData from UserDefaults
        let citiesDataArray = UserDefaults.standard.array(forKey: kCitiesUserDefaultsKey) as? [Data]
        XCTAssertEqual(citiesDataArray?.count, 0)   //  As we cleared data in UserDefaults, count should be 0

        for city in self.citiesArray {
            citySearchVC.appendNewCityToUserDefaultsArrayWith(city: city)
        }
        //  As we have only 2 citis data in mock data, above code will saves 2 cities in UserDefaults
        let citiesDataArray2 = UserDefaults.standard.array(forKey: kCitiesUserDefaultsKey) as? [Data]
        XCTAssertEqual(citiesDataArray2?.count, 2)
    }
    
    
    //MARK:- Utility methods
    fileprivate func parseCitiesData() {
        if let mockCitiesData = self.getMockDataFromJsonFile(name: "CitySearchJson") {
            do {
                let citiesList = try JSONDecoder().decode(SearchAPI.self, from: mockCitiesData)
                self.citiesArray = citySearchVC.parseCitiesWith(citiesList)
            } catch {
                print("JSON Data Parsing Error : \(error)")
            }
        }
    }

    fileprivate func getMockDataFromJsonFile(name : String) -> Data? {
        let testBundle = Bundle(for: type(of: self))
        let url = testBundle.url(forResource: name, withExtension: "json")

        do {
            let data = try Data(contentsOf: url!)
            return data
        }catch {
            //Handle Error
        }
        return nil
    }

}
