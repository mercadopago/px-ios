//
//  TrackStorageManager.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 6/27/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class TrackStorageManager: NSObject {

    static var MAX_BATCH_SIZE = SETTING_MAX_BATCH_SIZE
    static var MAX_AGEING: Double  = SETTING_MAX_AGEING
    static var MAX_LIFETIME: Double = SETTING_MAX_LIFETIME
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
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss a"
        let interval = -MAX_LIFETIME * 24 * 60 * 60
        let limitDayToKeep = Date().addingTimeInterval(TimeInterval(interval))
        let lastScreens = screenTrackArray.filter {
            let date = formatter.date(from:$0.timestamp)
            if date == nil {
                return false
            }
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

        var screenTrackArray = [ScreenTrackInfo]()
        for trackScreenJSON in arrayScreen {
            screenTrackArray.append(ScreenTrackInfo(from: JSONHandler.convertToDictionary(text: trackScreenJSON)!))
        }
        var lastScreens = screenTrackArray.sorted { $0.timestamp < $1.timestamp}
        let lastScreenTrack = lastScreens.first

        guard let lastTrack = lastScreenTrack else {
            return nil
        }
        // Validar que el track mas viejo
        if !force && !forceCauseAgeing(lastTrack: lastTrack) {
            return nil
        }

        let newArray = lastScreens.suffix(MAX_BATCH_SIZE)
        lastScreens.safeRemoveLast(MAX_BATCH_SIZE)
        var screenTrackJSONArray = [String]()
        for trackScreen in lastScreens {
            screenTrackJSONArray.append(trackScreen.toJSONString())
        }
        UserDefaults.standard.setValue(screenTrackJSONArray, forKey: SCREEN_TRACK_INFO_ARRAY_KEY)
        if newArray.count == 0 {
            return nil
        }
        return Array(newArray)
    }

    static func forceCauseAgeing(lastTrack: ScreenTrackInfo) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss a"
        let interval = -TrackStorageManager.MAX_AGEING
        let limitDayToAgeing = Date().addingTimeInterval(TimeInterval(interval))
        let date = formatter.date(from:lastTrack.timestamp)
        return date! < limitDayToAgeing
    }
}

extension TrackStorageManager {
    private static let kMaxBatchSize = "max_batch_size"
    private static let kMaxAgeing = "max_ageing"
    private static let kMaxLifetime = "max_lifetime"
    static let SCREEN_TRACK_INFO_ARRAY_KEY = "screens-tracks-info"
    static var SETTING_MAX_BATCH_SIZE: Int {
        get {
            guard let trackiSettings: [String:Any] = Utils.getSetting(identifier: MPXTracker.kTrackingSettings) else {
                return 0
            }
            guard let trackingEnabled = trackiSettings[TrackStorageManager.kMaxBatchSize] as? Int else {
                return 0
            }
            return trackingEnabled
        }
    }
    static var SETTING_MAX_AGEING: Double {
        get {
            guard let trackiSettings: [String:Any] = Utils.getSetting(identifier: MPXTracker.kTrackingSettings) else {
                return 0
            }
            guard let maxAgening = trackiSettings[TrackStorageManager.kMaxAgeing] as? Double else {
                return 0
            }
            return maxAgening
        }
    }
    static var SETTING_MAX_LIFETIME: Double {
        get {
            guard let trackiSettings: [String:Any] = Utils.getSetting(identifier: MPXTracker.kTrackingSettings) else {
                return 0
            }
            guard let maxLifetime = trackiSettings[TrackStorageManager.kMaxLifetime] as? Double else {
                return 0
            }
            return maxLifetime
        }
}
}
