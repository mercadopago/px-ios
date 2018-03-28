//
//  PXTimerService.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 28/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

protocol PXTimerChangesDelegate: NSObjectProtocol {
    func timerValueDidChange(timerDisplayValue: String)
}

protocol PXTimerLifecycleDelegate: NSObjectProtocol {
    func didFinishTimer()
}

class PXTimerService {
    
    fileprivate lazy var timer = Timer()
    fileprivate lazy var seconds: Int = 0
    fileprivate lazy var isRunning = false
    
    weak var changesDelegate: PXTimerChangesDelegate?
    weak var lifecycleDelegate: PXTimerLifecycleDelegate?
    
    init(withSeconds: Int) {
        seconds = withSeconds
    }
    
    func startTimer() {
        if seconds > 0 {
            if !isRunning {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(PXTimerService.updateTimer)), userInfo: nil, repeats: true)
                isRunning = true
            }
        }
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            lifecycleDelegate?.didFinishTimer()
        } else {
            seconds -= 1
            let newValue = getDisplayValue(forTime: TimeInterval(seconds))
            changesDelegate?.timerValueDidChange(timerDisplayValue: newValue)
            #if DEBUG
                print(newValue)
            #endif
        }
    }
    
    fileprivate func getDisplayValue(forTime: TimeInterval) -> String {
        // let hours = Int(forTime) / 3600
        let minutes = Int(forTime) / 60 % 60
        let seconds = Int(forTime) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}

struct PXTimerRenderer {
    func render(timerDisplayValue: String, yPosition: CGFloat) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        label.text = timerDisplayValue
        label.backgroundColor = UIColor(red: 0.21, green: 0.20, blue: 0.20, alpha: 0.8)
        label.textColor = .white
        let newSize: CGSize = timerDisplayValue.size(attributes: [NSFontAttributeName: label.font])
        label.frame = CGRect(x: PXLayout.getScreenWidth() - newSize.width - 8, y: yPosition, width: newSize.width + 2, height: newSize.height)
        return label
    }
}
