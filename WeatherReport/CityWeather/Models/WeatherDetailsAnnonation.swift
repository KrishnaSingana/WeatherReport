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
    let currentHumudity : Int
    let currentWeatherText : String
    let currentTempC : Int
    let currentTempF : Int
    let coordinate: CLLocationCoordinate2D

    init(weatherImageUrl: String, currentHumudity: Int, currentWeatherText: String, currentTempC: Int, currentTempF: Int, coordinate: CLLocationCoordinate2D) {
        self.currentWeatherImageUrl = weatherImageUrl
        self.currentHumudity = currentHumudity
        self.currentWeatherText = currentWeatherText
        self.currentTempC = currentTempC
        self.currentTempF = currentTempF
        self.coordinate = coordinate

        super.init()
    }

}
