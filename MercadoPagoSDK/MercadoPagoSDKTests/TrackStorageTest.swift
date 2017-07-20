//
//  TrackStorageTest.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 6/30/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest
/*

class TrackStorageTest: BaseTest {

    override func setUp() {
        super.setUp()
        UserDefaults.standard.setValue([String](), forKey: TrackStorageManager.SCREEN_TRACK_INFO_ARRAY_KEY)
        TrackStorageManager.MAX_DAYS_IN_STORAGE = 7
        MPXTracker.sharedInstance.trackingStrategy = PersistAndTrack(attemptSendEachTrack: false)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTrackNEventStorage() {
        var i = 0
        let N = TrackStorageManager.MIN_TRACKS_PER_REQUEST - 1
        while i < N {
            DummyContext.trackScreen(screenId: "PULPO_ID_\(i)", screenName: "PULPO_SCREEN_\(i)")
            i += 1
        }
        var array = UserDefaults.standard.array(forKey: TrackStorageManager.SCREEN_TRACK_INFO_ARRAY_KEY)
        XCTAssert(array?.count == N)
        var batchArray = TrackStorageManager.getBatchScreenTracks()
        XCTAssert(batchArray == nil)
        DummyContext.trackScreen(screenId: "LAST_ID", screenName: "LAST_SCREEN")
        batchArray = TrackStorageManager.getBatchScreenTracks()
        XCTAssert(batchArray?.count == TrackStorageManager.MIN_TRACKS_PER_REQUEST)
        array = UserDefaults.standard.array(forKey: TrackStorageManager.SCREEN_TRACK_INFO_ARRAY_KEY)
        XCTAssert(array?.count == 0)
    }

    func testClean() {
        var i = 0
        let N = TrackStorageManager.MIN_TRACKS_PER_REQUEST
        while i < N {
            DummyContext.trackScreen(screenId: "PUL PO_ID_\(i)", screenName: "PULPO_SCREEN_\(i)")
            i += 1
        }
        var batchArray = TrackStorageManager.getBatchScreenTracks()
        XCTAssert(batchArray?.count == TrackStorageManager.MIN_TRACKS_PER_REQUEST)
        TrackStorageManager.persist(screenTrackInfoArray: batchArray!)
        TrackStorageManager.MAX_DAYS_IN_STORAGE = Double(1 / 24 / 60 / 60)
        sleep(1)
        batchArray = TrackStorageManager.getBatchScreenTracks()
        XCTAssert(batchArray == nil)
    }

}
*/
