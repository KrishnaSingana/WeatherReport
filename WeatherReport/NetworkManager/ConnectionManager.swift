//
//  ConnectionManager.swift
//  WeatherReport
//
//  Created by Krishna Singana on 23/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import Foundation

class ConnectionManager {
    
    static let sharedInstance = ConnectionManager()
    fileprivate let baseURL = "http://api.worldweatheronline.com/premium/v1/"

    func generatePollutionApiURLWithSearchText(searchText : String) -> String {
        let endPointURL = "search.ashx?popular=yes&key=336c1ae9a81e44ec9de90335192012&format=json&q="
        let hostURL = "\(baseURL)\(endPointURL)\(searchText)"
        return hostURL
    }

    func getPollutionApiRequestWithSearchText(searchText : String) -> URLRequest? {
        if let request:URLRequest = self.baseRequestForURL(url: self.generatePollutionApiURLWithSearchText(searchText: searchText), method: "GET") {
            return request
        }
        return nil
    }

    //This method is used to provide basic common information required while creating URLRequest.
    private func baseRequestForURL(url: String, contentType: String? = nil, httpBody: [String:Any]? = nil, method: String) -> URLRequest? {
        if let url = URL(string: url) {
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = method
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let body = httpBody as? [String : String], method == "POST" || method == "PUT" {
                let jsonData = try? JSONSerialization.data(withJSONObject: body)
                request.httpBody = jsonData
            }
            return request as URLRequest
        } else {
            return nil
        }
    }

}
