//
//  ErrorTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 7/4/15.
//  Copyright (c) 2015 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

open class ErrorTableViewCell : UITableViewCell {
    var errorView : GenericErrorView?
    open var height : CGFloat = 0
    
    open func setError(_ error: String?) {
        if error == nil {
            if self.errorView != nil {
                self.errorView!.removeFromSuperview()
            }
        } else {
            self.errorView = GenericErrorView(frame: CGRect(x: 0, y: height, width: self.frame.width, height: 0))
            self.errorView!.setErrorMessage(error!)
            self.addSubview(self.errorView!)
        }
    }
	
	open func focus() {
	}
    
    open func hasError() -> Bool {
        return self.errorView != nil
    }
    
    open func getHeight() -> CGFloat {
        var error : CGFloat = 0
        if self.hasError() {
            error = self.errorView!.frame.height
        }
        return error + height
    }
}
