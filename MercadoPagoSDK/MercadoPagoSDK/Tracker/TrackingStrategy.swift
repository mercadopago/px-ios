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
    func trackLastScreen(screenTrack: ScreenTrackInfo)
}

class PersistAndTrack: TrackingStrategy {

    var attemptSendForEachTrack = false

    init(attemptSendEachTrack: Bool = false) {
        self.attemptSendForEachTrack = attemptSendEachTrack
    }
    func trackLastScreen(screenTrack: ScreenTrackInfo) {
        TrackStorageManager.persist(screenTrackInfo: screenTrack)
        attemptSendTrackInfo(force:true)
    }
    func trackScreen(screenTrack: ScreenTrackInfo) {
        TrackStorageManager.persist(screenTrackInfo: screenTrack)
        if attemptSendForEachTrack {
            attemptSendTrackInfo()
        }
    }

    func canSendTrack(force: Bool = false) -> Bool {
        let status = Reach().connectionStatus()
        if status.description == "Offline" {
            return false
        }
        if force {
            return true
        }
        return status.description == "Online (WiFi)" || UIApplication.shared.applicationState == UIApplicationState.background
    }

    func attemptSendTrackInfo(force: Bool = false) {
        if canSendTrack(force:force) {
            let array = TrackStorageManager.getBatchScreenTracks(force: force)
            guard let batch = array else {
                return
            }
            send(trackList: batch)
            attemptSendTrackInfo(force: force)
        }else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
                self.attemptSendTrackInfo(force: force)
            })
        }
    }
    private func send(trackList: Array<ScreenTrackInfo>) {
        var jsonBody = MPXTracker.generateJSONDefault()
        var arrayEvents = Array<[String:Any]>()
        for elementToTrack in trackList {
            arrayEvents.append(elementToTrack.toJSON())
        }
        jsonBody["events"] = arrayEvents
        let body = JSONHandler.jsonCoding(jsonBody)
        TrackingServices.request(url: "https://api.mercadopago.com/beta/checkout/tracking/events", params: nil, body: body, method: "POST", headers: nil, success: { (result) -> Void in
            print("TRACKED!")
        }) { (error) -> Void in
            TrackStorageManager.persist(screenTrackInfoArray: trackList) // Vuelve a guardar los tracks que no se pudieron trackear
        }
    }

}
