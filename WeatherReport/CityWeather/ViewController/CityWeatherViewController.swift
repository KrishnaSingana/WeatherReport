//
//  CityWeatherViewController.swift
//  WeatherReport
//
//  Created by Krishna Singana on 23/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import UIKit
import MapKit

class CityWeatherViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var selectedCity : City!
    fileprivate let regionRadius: CLLocationDistance = 60000
    fileprivate let connectionManagerInstance = ConnectionManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        let latitude = Double(selectedCity?.latitude ?? "0")
        let longitude = Double(selectedCity?.longitude ?? "0")
        let initialLocationOnMap = CLLocation(latitude: latitude ?? 0.0, longitude: longitude ?? 0.0)
        self.centerMapOnLocation(location: initialLocationOnMap)
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let latitude = self.selectedCity.latitude, let longitude = self.selectedCity.longitude else {
            return
        }
        self.getCityWeatherDetailsFor(latitude, longitude)
    }
    
    //  This method is used for showing complete singapore map on screen.
    fileprivate func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

// MARK: - MapKit Delegate methods
extension CityWeatherViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? WeatherDetailsAnnonation else { return nil }
        let annotationViewIdentifier = "annotationViewIdentifier"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationViewIdentifier)
            as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationViewIdentifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
        }

        let annonationView = self.createAnnonationView(annotation)
        view.detailCalloutAccessoryView = annonationView
        view.animatesDrop = true
         let widthConstraint = NSLayoutConstraint(item: annonationView,
                                                  attribute: .width, relatedBy: .equal, toItem: nil,
                                                  attribute: .notAnAttribute, multiplier: 1, constant: 300)
         let heightConstraint = NSLayoutConstraint(item: annonationView,
                                                   attribute: .height, relatedBy: .equal, toItem: nil,
                                                   attribute: .notAnAttribute, multiplier: 1, constant: 300)

         annonationView.addConstraints([widthConstraint, heightConstraint])

        return view
    }
}

extension CityWeatherViewController {
    fileprivate func getCityWeatherDetailsFor(_ latitude: String, _ longitude: String) {
        Common.sharedCommonInstance.showIndicatorViewOnScreen(viewController: self)
        let defaultSession = URLSession(configuration: .default)
        
        let dataTask = defaultSession.dataTask(with:  connectionManagerInstance.getCityWeatherDetailsApiRequestFor(
            latitude, longitude)!) { data, response , error in
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                guard let weatherData = data else { return }
                do {
                    let weatherDetails = try JSONDecoder().decode(WeatherData.self, from: weatherData)
                    DispatchQueue.main.async {
                        self.parseWeatherDetails(weatherDetails)
                    }
                } catch {
                    print("JSON Data Parsing Error : \(error)")
                }
            } else {
                Common.sharedCommonInstance
                    .showAlertWith("", "Weather details not found for \(self.selectedCity.areaName?[0].value ?? "").",
                        onScreen: self)
            }
            Common.sharedCommonInstance.hideIndicatorViewOnScreen(viewController: self)
        }
        dataTask.resume()
    }
    
    fileprivate func parseWeatherDetails(_ weatherDetails : WeatherData) {
        let currentWeather = weatherDetails.data?.currentCondition?[0]
        guard let weather = currentWeather else {
            return
        }
        self.createAnnotationFor(weather)
    }
    
    //  This is used for creating Pin Annonations based on Location points that fetched from api.
    fileprivate func createAnnotationFor(_ currentWeather: CurrentWeather) {
        guard let imageURL = currentWeather.weatherIconUrl?[0].value else { return }
        guard let weatherText = currentWeather.weatherDesc?[0].value else { return }
        let weatherAnnotation = WeatherDetailsAnnonation(
            weatherImageUrl: imageURL, currentHumudity: currentWeather.humidity ?? "0", currentWeatherText: weatherText,
            currentTempC: currentWeather.tempC ?? "0", currentTempF: currentWeather.tempF ?? "0",
            coordinate: CLLocationCoordinate2D(latitude: Double(selectedCity?.latitude ?? "0.0")!,
                                               longitude: Double(selectedCity?.longitude ?? "0.0")!))
        self.mapView.addAnnotation(weatherAnnotation)
        self.mapView.selectAnnotation(weatherAnnotation, animated: true)
    }

    fileprivate func createAnnonationView(_ annonationObj: WeatherDetailsAnnonation) -> UIView {
        let annonationView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        annonationView.backgroundColor = UIColor(red: 227.0/255.0, green: 197.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        
        let titleMessage = "\(selectedCity?.areaName?[0].value ?? ""), \(selectedCity?.country?[0].value ?? "")"

        let titleLbl = UILabel(frame: CGRect(x: 16, y: 4, width: 268, height: 30))
        titleLbl.text = titleMessage
        titleLbl.textAlignment = .center
        titleLbl.font = UIFont.boldSystemFont(ofSize: 18)
        titleLbl.textColor = .black
        annonationView.addSubview(titleLbl)
        
        let imageUrl = URL(string: annonationObj.currentWeatherImageUrl)
        let weatherImage = UIImageView(frame: CGRect(x: 80, y: 42, width: 140, height: 100))
        weatherImage.load(url: imageUrl!)
        weatherImage.backgroundColor = .clear
        annonationView.addSubview(weatherImage)
        
        let weatherNameLbl = UILabel(frame: CGRect(x: 16, y: 150, width: 268, height: 40))
        weatherNameLbl.text = annonationObj.currentWeatherText
        weatherNameLbl.textAlignment = .center
        weatherNameLbl.font = UIFont.boldSystemFont(ofSize: 30)
        weatherNameLbl.textColor = .black
        annonationView.addSubview(weatherNameLbl)

        let tempatureImage = UIImageView(frame: CGRect(x: 24, y: 200, width: 30, height: 30))
        tempatureImage.image = UIImage(named: "temparatureIcon")
        tempatureImage.backgroundColor = .clear
        annonationView.addSubview(tempatureImage)

        let temperatureLbl = UILabel(frame: CGRect(x: 56, y: 200, width: 80, height: 30))
        temperatureLbl.text = "\(annonationObj.currentTempC)°C"
        temperatureLbl.textAlignment = .left
        temperatureLbl.font = UIFont.systemFont(ofSize: 26)
        temperatureLbl.textColor = .black
        annonationView.addSubview(temperatureLbl)

        let humidityImage = UIImageView(frame: CGRect(x: 174, y: 200, width: 30, height: 30))
        humidityImage.image = UIImage(named: "humidityImage")
        humidityImage.backgroundColor = .clear
        annonationView.addSubview(humidityImage)

        let humidityLbl = UILabel(frame: CGRect(x: 210, y: 200, width: 80, height: 30))
        humidityLbl.text = "\(annonationObj.currentHumudity)%"
        humidityLbl.textAlignment = .left
        humidityLbl.font = UIFont.systemFont(ofSize: 26)
        humidityLbl.textColor = .black
        annonationView.addSubview(humidityLbl)
        
        return annonationView
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
