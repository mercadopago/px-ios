//
//  File.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 7/5/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

protocol TrackingStrategy {
    func trackScreen(screenTrack: ScreenTrackInfo)
}

class RealTimeStrategy: TrackingStrategy { // V1
    func trackScreen(screenTrack: ScreenTrackInfo) {
     self.send(trackList: [screenTrack])
    }
    private func send(trackList: [ScreenTrackInfo]) {
        var jsonBody = MPXTracker.generateJSONDefault()
        var arrayEvents = [[String: Any]]()
        for elementToTrack in trackList {
            arrayEvents.append(elementToTrack.toJSON())
        }
        jsonBody["events"] = arrayEvents
        let body = JSONHandler.jsonCoding(jsonBody)
        TrackingServices.request(url: MPXTracker.TRACKING_URL, params: nil, body: body, method: "POST", headers: nil, success: { _ -> Void in
        }, failure: { _ -> Void in
        })
    }
}

class BatchStrategy: TrackingStrategy { // V2

    func trackScreen(screenTrack: ScreenTrackInfo) {
        TrackStorageManager.persist(screenTrackInfo: screenTrack)
        attemptSendTrackInfo()
    }

    func canSendTrack() -> Bool {
        let status = MPXReach().connectionStatus()
        if status.description == "Offline" {
            return false
        }
        return status.description == "Online (WiFi)" || UIApplication.shared.applicationState == UIApplicationState.background
    }

    func attemptSendTrackInfo() {
        if canSendTrack() {
            let array = TrackStorageManager.getBatchScreenTracks(force: false)
            guard let batch = array else {
                return
            }
            send(trackList: batch)
        }
    }
    private func send(trackList: [ScreenTrackInfo]) {
        var jsonBody = MPXTracker.generateJSONDefault()
        var arrayEvents = [[String: Any]]()
        for elementToTrack in trackList {
            arrayEvents.append(elementToTrack.toJSON())
        }
        jsonBody["events"] = arrayEvents
        let body = JSONHandler.jsonCoding(jsonBody)
        TrackingServices.request(url: MPXTracker.TRACKING_URL, params: nil, body: body, method: "POST", headers: nil, success: {  _ -> Void in
        }, failure: { _ -> Void in
            TrackStorageManager.persist(screenTrackInfoArray: trackList) // Vuelve a guardar los tracks que no se pudieron trackear
        })
    }

}

class ForceTrackStrategy: TrackingStrategy { // V2

    func trackScreen(screenTrack: ScreenTrackInfo) {
        TrackStorageManager.persist(screenTrackInfo: screenTrack)
        attemptSendTrackInfo(force: true)
    }

    func canSendTrack() -> Bool {
        let status = MPXReach().connectionStatus()
        if status.description == "Offline" {
            return false
        }
        return true
    }

    func attemptSendTrackInfo(force: Bool = false) {
        if canSendTrack() {
            let array = TrackStorageManager.getBatchScreenTracks(force: true)
            guard let batch = array else {
                return
            }
            send(trackList: batch)
            attemptSendTrackInfo(force: force)
        }
    }
    private func send(trackList: [ScreenTrackInfo]) {
        var jsonBody = MPXTracker.generateJSONDefault()
        var arrayEvents = [[String: Any]]()
        for elementToTrack in trackList {
            arrayEvents.append(elementToTrack.toJSON())
        }
        jsonBody["events"] = arrayEvents
        let body = JSONHandler.jsonCoding(jsonBody)
        TrackingServices.request(url: MPXTracker.TRACKING_URL, params: nil, body: body, method: "POST", headers: nil, success: { _ -> Void in
        }, failure: { _ -> Void in
            TrackStorageManager.persist(screenTrackInfoArray: trackList) // Vuelve a guardar los tracks que no se pudieron trackear
        })
    }

}
