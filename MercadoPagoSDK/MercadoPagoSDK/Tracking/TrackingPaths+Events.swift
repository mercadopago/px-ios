//
//  TrackingPaths+Events.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 29/10/2018.
//

import Foundation

// MARK: Events
extension TrackingPaths {
    internal struct Events {
        static func getErrorPath() -> String {
            return "/friction"
        }

        static func getConfirmPath() -> String {
            return TrackingPaths.pxTrack + "/review/confirm"
        }
    }
}

extension TrackingPaths.Events {
    internal struct OneTap {
        static func getAbortPath() -> String {
            return TrackingPaths.pxTrack + "/review/one_tap/abort"
        }

        static func getSwipePath() -> String {
            return TrackingPaths.pxTrack + "/review/one_tap/swipe"
        }

        static func getConfirmPath() -> String {
            return TrackingPaths.pxTrack + "/review/confirm"
        }
    }
}
