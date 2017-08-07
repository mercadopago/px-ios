//
//  PromosService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 22/5/15.
//  Copyright (c) 2015 MercadoPago. All rights reserved.
//

import Foundation

open class PromosService: MercadoPagoService {

	open func getPromos(_ url: String = ServicePreference.MP_PROMOS_URI, method: String = "GET", public_key: String, success: @escaping (_ jsonResult: AnyObject?) -> Void, failure: ((_ error: NSError) -> Void)?) {
		self.request(uri: url, params: "public_key=" + public_key, body: nil, method: method, success: success, failure: failure)
	}

}
