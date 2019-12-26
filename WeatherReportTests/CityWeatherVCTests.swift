//
//  CityWeatherVCTests.swift
//  WeatherReportTests
//
//  Created by Krishna Singana on 26/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import XCTest
@testable import WeatherReport

class CityWeatherVCTests: XCTestCase {

    var cityWeatherVC: CityWeatherViewController!
    var weatherReportTestObj = WeatherReportTests()

    override func setUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let weatherVC: CityWeatherViewController = storyboard.instantiateViewController(withIdentifier:
            String(describing: CityWeatherViewController.self)) as! CityWeatherViewController
        cityWeatherVC = weatherVC
        _ = cityWeatherVC.view
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWeatherDetails() {
        guard let currentWeather = self.parseWeatherDetails() else {
            XCTFail("Not able to parse WeatherDetails")
            return
        }
        XCTAssertEqual(currentWeather.humidity, "71")
        XCTAssertEqual(currentWeather.tempC, "11")
        XCTAssertEqual(currentWeather.tempF, "52")
    }

    func testCreateAnnonations() {
        guard let currentWeather = self.parseWeatherDetails() else {
            XCTFail("Not able to parse WeatherDetails")
            return
        }
        let annonationsBeforeCreating = cityWeatherVC.mapView.annotations
        XCTAssertEqual(annonationsBeforeCreating.count, 0)
        cityWeatherVC.createAnnotationFor(currentWeather)
        let annonationsAfterCreating = cityWeatherVC.mapView.annotations
        XCTAssertEqual(annonationsAfterCreating.count, 1)
    }

    func testCretingAnnonationViewDetailCalloutAccessoryView() {
        guard let currentWeather = self.parseWeatherDetails() else {
            XCTFail("Not able to parse WeatherDetails")
            return
        }
        cityWeatherVC.createAnnotationFor(currentWeather)
        let annonations = cityWeatherVC.mapView.annotations
        guard let annonation = annonations[0] as? WeatherDetailsAnnonation else {
            return
        }
        let annonationAccessoryView = cityWeatherVC.createAnnonationView(annonation)
        XCTAssertNotNil(annonationAccessoryView)
    }

    fileprivate func parseWeatherDetails() -> CurrentWeather? {
        if let mockCityWeatherData = weatherReportTestObj.getMockDataFromJsonFile(name: "CityWeatherDetails") {
            do {
                let weatherDetails = try JSONDecoder().decode(WeatherData.self, from: mockCityWeatherData)
                let currentWeather = cityWeatherVC.parseWeatherDetails(weatherDetails)
                return currentWeather
            } catch {
                print("JSON Data Parsing Error : \(error)")
                return nil
            }
        }
        return nil
    }

}
