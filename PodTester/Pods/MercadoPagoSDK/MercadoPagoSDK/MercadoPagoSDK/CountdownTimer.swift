//
//  CountdownTimer.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 10/17/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class CountdownTimer: NSObject {
    
    private static let instance = CountdownTimer()
    
    var timer : Timer?
    var secondsLeft = 0
    var timeoutCallback : ((Void) -> Void?)!
    weak var delegate : TimerDelegate!
    
    open func setup(seconds : Int, timeoutCallback : @escaping (Void) -> Void) {
        self.secondsLeft = seconds
        self.timeoutCallback = timeoutCallback
        
        // Timer already created in older purchase trial
        if self.timer != nil {
            self.timer!.invalidate()
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 1,
                                                    target: self,
                                                    selector: #selector(self.updateTimer),
                                                    userInfo: nil,
                                                    repeats: true)
    }
    
    open static func getInstance() -> CountdownTimer {
        return CountdownTimer.instance
    }
    
    open func hasTimer() -> Bool {
        return self.timer != nil
    }
    
    open func updateTimer(){
        
        //print("timer retain count \(CFGetRetainCount(self))")
        
        guard let delegate = self.delegate  else {
            self.timer!.invalidate()
            return
        }
        secondsLeft -= 1
        delegate.updateTimer()
        
        if secondsLeft == 0 {
            stopTimer()
            timeoutCallback()
        }
    }
    
    open func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    open func getCurrentTiming() -> String {
        var hoursStr = "", minutesStr = "", secondsStr = ""
        
        var minutes = secondsLeft / 60
        if minutes >= 60 {
            let hours = minutes / 60
            if hours < 10 {
                hoursStr = "0"
            }
            hoursStr += String(hours)
            minutes = minutes % 60
        }
        
        
        if minutes < 10  && minutes >= 0{
            minutesStr = "0"
        }
        minutesStr += String(minutes)
        
        let seconds = secondsLeft % 60
        if seconds < 10 && seconds >= 0 {
            secondsStr = "0"
        }
        secondsStr += String(seconds)
        
        return (hoursStr.characters.count > 0) ? (hoursStr + " : " + minutesStr + " : " + secondsStr) : (minutesStr + " : " + secondsStr)
    }
    deinit {
        //print("Limpie el timer")
    }
    
}

@objc public protocol TimerDelegate {
    
    @objc func updateTimer()
    
}
