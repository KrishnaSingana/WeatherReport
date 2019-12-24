//
//  CityWeatherDetails.swift
//  WeatherReport
//
//  Created by Krishna Singana on 24/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import Foundation

struct WeatherData: Codable {
    var data: WeatherDetails?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decodeIfPresent(WeatherDetails.self, forKey: .data)
    }
}

struct WeatherDetails: Codable {
    var currentCondition: [CurrentWeather]?
    
    private enum CodingKeys: String, CodingKey {
        case currentCondition = "current_condition"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentCondition = try container.decodeIfPresent([CurrentWeather].self, forKey: .currentCondition)
    }
}

struct CurrentWeather: Codable {
    var weatherIconUrl: [GenericModel]?
    var weatherDesc: [GenericModel]?
    var humidity: String?
    var tempC: String?
    var tempF: String?
    
    private enum CodingKeys: String, CodingKey {
        case weatherIconUrl
        case weatherDesc
        case humidity
        case tempC = "temp_C"
        case tempF = "temp_F"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        weatherIconUrl = try container.decodeIfPresent([GenericModel].self, forKey: .weatherIconUrl)
        weatherDesc = try container.decodeIfPresent([GenericModel].self, forKey: .weatherDesc)
        humidity = try container.decodeIfPresent(String.self, forKey: .humidity)
        tempC = try container.decodeIfPresent(String.self, forKey: .tempC)
        tempF = try container.decodeIfPresent(String.self, forKey: .tempF)
    }
}
