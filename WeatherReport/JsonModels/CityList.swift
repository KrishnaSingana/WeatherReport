//
//  CityList.swift
//  WeatherReport
//
//  Created by Krishna Singana on 23/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import Foundation

struct SearchAPI: Codable {
    var searchApi: ListOfCities?

    private enum CodingKeys: String, CodingKey {
        case searchApi = "search_api"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        searchApi = try container.decodeIfPresent(ListOfCities.self, forKey: .searchApi)
    }
}

struct ListOfCities: Codable {
    var citiesList: [City]?

    private enum CodingKeys: String, CodingKey {
        case citiesList = "result"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        citiesList = try container.decodeIfPresent([City].self, forKey: .citiesList)
    }
}
struct City: Codable {
    var areaName: [GenericModel]?
    var country: [GenericModel]?
    var region: [GenericModel]?
    var weatherUrl: [GenericModel]?
    var latitude: String?
    var longitude: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        areaName = try container.decodeIfPresent([GenericModel].self, forKey: .areaName)
        country = try container.decodeIfPresent([GenericModel].self, forKey: .country)
        region = try container.decodeIfPresent([GenericModel].self, forKey: .region)
        weatherUrl = try container.decodeIfPresent([GenericModel].self, forKey: .weatherUrl)
        latitude = try container.decodeIfPresent(String.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(String.self, forKey: .longitude)
    }
}

struct GenericModel: Codable {
    var value: String?
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decodeIfPresent(String.self, forKey: .value)
    }
}
