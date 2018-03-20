//
//  QRReaderViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 20/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit
import AVFoundation

class QRReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var video = AVCaptureVideoPreviewLayer()
    var shouldShow = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Scan QR Code"
//        setupQRCodeReader()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldShow = true
        setupQRCodeReader()
    }
    
    func setupQRCodeReader() {
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
    
    func QRCodeFound(_ data: String) {
        playFoundSound()
        hapticFeedback()
        
        let vc = ExpressViewController()
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false, completion: {
            print("Done")
        })
    }
    
    func hapticFeedback() {
        if #available(iOS 10.0, *) {
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.error)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func playFoundSound() {
        let systemSoundID: SystemSoundID = 1109
        AudioServicesPlaySystemSound (systemSoundID)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

