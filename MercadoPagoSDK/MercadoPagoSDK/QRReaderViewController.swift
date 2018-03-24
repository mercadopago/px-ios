//
//  QRReaderViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 20/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit
import AVFoundation

class QRReaderViewController: UIViewController {
    
    lazy var video = AVCaptureVideoPreviewLayer()
    var shouldShow = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Scan QR Code"
        // setupQRCodeReader()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldShow = true
        if TARGET_OS_SIMULATOR != 0 {
            QRCodeFound("")
        } else {
            setupQRCodeReader()
        }
    }
    
    fileprivate func setupQRCodeReader() {
        //Creating session
        let session = AVCaptureSession()
        
        //Define capture devcie
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
        }
        catch {
            print ("ERROR")
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
        session.startRunning()
    }
    
    fileprivate func QRCodeFound(_ data: String) {
        playFoundSound()
        hapticFeedback()
        //let vc = ExpressViewController(viewModel: )
        //vc.modalPresentationStyle = .overCurrentContext
        //self.present(vc, animated: false, completion: {
            //print("Done")
        //})
    }
    
    fileprivate func hapticFeedback() {
        if #available(iOS 10.0, *) {
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.error)
        } else {
            // Fallback on earlier versions
        }
    }
    
    fileprivate func playFoundSound() {
        let systemSoundID: SystemSoundID = 1057
        AudioServicesPlaySystemSound (systemSoundID)
    }
}

extension QRReaderViewController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects != nil && metadataObjects.count != 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObjectTypeQRCode {
                    if shouldShow {
                        shouldShow = false
                        QRCodeFound(object.stringValue)
                    }
                }
            }
        }
    }
}
