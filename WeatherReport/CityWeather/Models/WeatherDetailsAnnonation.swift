//
//  WeatherDetailsAnnonation.swift
//  WeatherReport
//
//  Created by Krishna Singana on 24/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import UIKit
import MapKit

class WeatherDetailsAnnonation: NSObject, MKAnnotation {
    let currentWeatherImageUrl: String
    let currentHumudity: String
    let currentWeatherText: String
    let currentTempC: String
    let currentTempF: String
    let coordinate: CLLocationCoordinate2D

    init(weatherImageUrl: String, currentHumudity: String, currentWeatherText: String, currentTempC: String,
         currentTempF: String, coordinate: CLLocationCoordinate2D) {
        self.currentWeatherImageUrl = weatherImageUrl
        self.currentHumudity = currentHumudity
        self.currentWeatherText = currentWeatherText
        self.currentTempC = currentTempC
        self.currentTempF = currentTempF
        self.coordinate = coordinate

        super.init()
    }

}
