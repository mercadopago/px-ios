//
//  LocationService.swift
//  MercadoPagoSDK
//
//  Created by Jonathan Scaramal on 26/11/2020.
//

import Foundation
import CoreLocation

class LocationService {
  static func isLocationEnabled() -> Bool {
    
    var locationEnabled = false
    
    if CLLocationManager.locationServicesEnabled() {
      switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            print("No access")
        case .authorizedAlways, .authorizedWhenInUse:
            locationEnabled = true
        }
    } else {
        print("Location services are not enabled")
    }
    
    return locationEnabled
  }
}

  
