//
//  TrackStorageManager.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 6/27/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class TrackStorageManager: NSObject {

    static let SCREEN_TRACK_INFO_ARRAY_KEY = "screens-tracks-info"
    static let MAX_TRACKS_PER_REQUEST = 10
    static let MIN_TRACKS_PER_REQUEST = 10
    static var MAX_DAYS_IN_STORAGE: Double = 7

    //Guardo el ScreenTrackInfo serializado en el array del userDefaults, si el mismo no esta creado lo crea
    static func persist(screenTrackInfo: ScreenTrackInfo) {
        persist(screenTrackInfoArray: [screenTrackInfo])
    }
    //Guardo todos los elementos del array screenTrackInfoArray serializado en el array del userDefaults, si el mismo no esta creado lo crea
    static func persist(screenTrackInfoArray: [ScreenTrackInfo]) {
        var newArray = [String]()
        if let array = UserDefaults.standard.array(forKey: SCREEN_TRACK_INFO_ARRAY_KEY) as? [String] {
            newArray.append(contentsOf: array)
        }
        for trackScreen in screenTrackInfoArray {
            newArray.append(trackScreen.toJSONString())
        }
        UserDefaults.standard.setValue(newArray, forKey: SCREEN_TRACK_INFO_ARRAY_KEY)
    }

    private static func cleanStorage() {
        let array = UserDefaults.standard.array(forKey: SCREEN_TRACK_INFO_ARRAY_KEY)
        guard let arrayScreen = array as? [String] else {
            return
        }
        var screenTrackArray = [ScreenTrackInfo]()
        for trackScreenJSON in arrayScreen {
            screenTrackArray.append(ScreenTrackInfo(from: JSONHandler.convertToDictionary(text: trackScreenJSON)!))
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let interval = -MAX_DAYS_IN_STORAGE * 24 * 60 * 60
        let limitDayToKeep = Date().addingTimeInterval(TimeInterval(interval))
        let lastScreens = screenTrackArray.filter {
            let date = formatter.date(from:$0.timestamp)
            return date! > limitDayToKeep
        }
        var screenTrackJSONArray = [String]()
        for trackScreen in lastScreens {
            screenTrackJSONArray.append(trackScreen.toJSONString())
        }

        UserDefaults.standard.setValue(screenTrackJSONArray, forKey: SCREEN_TRACK_INFO_ARRAY_KEY)
    }

    //Devuevle un array con los MAX_TRACKS_PER_REQUEST ultimos screenstrackinfo
    static func getBatchScreenTracks(force: Bool = false) -> [ScreenTrackInfo]? {
        cleanStorage()
        let array = UserDefaults.standard.array(forKey: SCREEN_TRACK_INFO_ARRAY_KEY)
        guard let arrayScreen = array as? [String] else {
            return nil
        }
        if arrayScreen.count < MIN_TRACKS_PER_REQUEST && !force {
            return nil
        }
        var screenTrackArray = [ScreenTrackInfo]()
        for trackScreenJSON in arrayScreen {
            screenTrackArray.append(ScreenTrackInfo(from: JSONHandler.convertToDictionary(text: trackScreenJSON)!))
        }
        var lastScreens = screenTrackArray.sorted { $0.timestamp < $1.timestamp}
        let newArray = lastScreens.suffix(MAX_TRACKS_PER_REQUEST)
        lastScreens.safeRemoveLast(MAX_TRACKS_PER_REQUEST)
        var screenTrackJSONArray = [String]()
        for trackScreen in lastScreens {
            screenTrackJSONArray.append(trackScreen.toJSONString())
        }
        UserDefaults.standard.setValue(screenTrackJSONArray, forKey: SCREEN_TRACK_INFO_ARRAY_KEY)
        return Array(newArray)
    }

}
