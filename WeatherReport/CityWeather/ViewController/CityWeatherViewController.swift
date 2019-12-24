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

    override func viewDidLoad() {
        super.viewDidLoad()

        let latitude = Double(selectedCity?.latitude ?? "0")
        let longitude = Double(selectedCity?.longitude ?? "0")
        let initialLocationOnMap = CLLocation(latitude: latitude ?? 0.0, longitude: longitude ?? 0.0)
        self.centerMapOnLocation(location: initialLocationOnMap)
        mapView.delegate = self
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

         let subTitleLabel = UILabel()
        subTitleLabel.text = annotation.currentWeatherText

         view.detailCalloutAccessoryView = subTitleLabel
        view.animatesDrop = true
         let widthConstraint = NSLayoutConstraint(item: subTitleLabel,
                                                  attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil,
                                                  attribute: .notAnAttribute, multiplier: 1, constant: 250)
         let heightConstraint = NSLayoutConstraint(item: subTitleLabel,
                                                   attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil,
                                                   attribute: .notAnAttribute, multiplier: 1, constant: 0)

         subTitleLabel.numberOfLines = 0
         subTitleLabel.addConstraints([widthConstraint, heightConstraint])

        return view
    }
}
