//
//  Common.swift
//  WeatherReport
//
//  Created by Krishna Singana on 23/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import Foundation
import UIKit

class Common {
    static let sharedCommonInstance = Common()
    var activityIndicator: UIActivityIndicatorView!

    func showIndicatorViewOnScreen(viewController: UIViewController) {
        DispatchQueue.main.async {
            if self.activityIndicator != nil {
                self.activityIndicator = nil
            }
            self.activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
            self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.activityIndicator.center = viewController.view.center
            self.activityIndicator.startAnimating()
            viewController.view.addSubview(self.activityIndicator)
            viewController.view.isUserInteractionEnabled = false
        }
    }

    func hideIndicatorViewOnScreen(viewController: UIViewController) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            self.activityIndicator = nil
            viewController.view.isUserInteractionEnabled = true
        }
    }

    func showAlertWith(_ title: String, _ message: String, onScreen viewController: UIViewController) {
        DispatchQueue.main.async {
            let errorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in

            }
            errorAlert.addAction(okAction)
            viewController.present(errorAlert, animated: true)
        }
    }

}
