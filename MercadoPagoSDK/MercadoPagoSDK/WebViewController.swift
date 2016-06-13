//
//  WebViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 22/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class WebViewController: MercadoPagoUIViewController, UIWebViewDelegate {
    
    var url : NSURL?
    @IBOutlet weak var webView: UIWebView!
    init( url : NSURL) {
        super.init(nibName: "WebViewController", bundle: MercadoPago.getBundle())
        self.url = url
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadUrl(url!)
        self.webView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        self.showLoading()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUrl(url : NSURL){
        let requestObj = NSURLRequest(URL: url);
        webView.loadRequest(requestObj);
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.hideLoading()
    }
    

}
