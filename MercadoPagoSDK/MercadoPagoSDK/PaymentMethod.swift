//
//  PaymentMethod.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

@objcMembers open class PaymentMethod: NSObject, Cellable {

    public var objectType: ObjectTypes = ObjectTypes.paymentMethod
    open var paymentMethodId: String!
    open var name: String!
    open var paymentTypeId: String!
    open var settings: [Setting]!
    open var additionalInfoNeeded: [String]!
    open var financialInstitutions: [FinancialInstitution]!
    open var accreditationTime: Int? // [ms]
    open var status: String!
    open var secureThumbnail: String!
    open var thumbnail: String!
    open var deferredCapture: String!
    open var minAllowedAmount: Double = 0
    open var maxAllowedAmount: Double!
    open var merchantAccountId: String?
    open var externalPaymentPluginImageData: NSData?

    public override init() {
        super.init()
    }

    public init(paymentMethodId: String, name: String, paymentTypeId: String) {
        self.paymentMethodId = paymentMethodId
        self.name = name
        self.paymentTypeId = paymentTypeId
    }

    open class func fromJSON(_ json: NSDictionary) -> PaymentMethod {
                let paymentMethod: PaymentMethod = PaymentMethod()
                paymentMethod.paymentMethodId = json["id"] as? String
                paymentMethod.name = json["name"] as? String

                if json["payment_type_id"] != nil && !(json["payment_type_id"]! is NSNull) {
                        paymentMethod.paymentTypeId = json["payment_type_id"] as! String
                    }

                if json["status"] != nil && !(json["status"]! is NSNull) {
                        paymentMethod.status = json["status"] as! String
                    }

                if json["secure_thumbnail"] != nil && !(json["secure_thumbnail"]! is NSNull) {
                        paymentMethod.secureThumbnail = json["secure_thumbnail"] as! String
                    }

                if json["thumbnail"] != nil && !(json["thumbnail"]! is NSNull) {
                        paymentMethod.thumbnail = json["thumbnail"] as! String
                    }

                if json["deferred_capture"] != nil && !(json["deferred_capture"]! is NSNull) {
                        paymentMethod.deferredCapture = json["deferred_capture"] as! String
                    }

                if json["max_allowed_amount"] != nil && !(json["max_allowed_amount"]! is NSNull) {
                        paymentMethod.maxAllowedAmount = json["max_allowed_amount"] as! Double
                }

                if json["max_allowed_amount"] != nil && !(json["max_allowed_amount"]! is NSNull) {
                        paymentMethod.maxAllowedAmount = json["max_allowed_amount"] as! Double
                    }

                if json["min_allowed_amount"] != nil && !(json["min_allowed_amount"]! is NSNull) {
                        paymentMethod.minAllowedAmount = json["min_allowed_amount"] as! Double
                    }

                if json["merchant_account_id"] != nil && !(json["merchant_account_id"]! is NSNull) {
                        paymentMethod.merchantAccountId = json["merchant_account_id"] as? String
                    }

                var settings: [Setting] = [Setting]()
                if let settingsArray = json["settings"] as? NSArray {
                        for index in 0..<settingsArray.count {
                                if let settingDic = settingsArray[index] as? NSDictionary {
                                        settings.append(Setting.fromJSON(settingDic))
                                    }
                            }
                    }
                paymentMethod.settings = settings.isEmpty ? nil : settings

                var additionalInfoNeeded: [String] = [String]()
                if let additionalInfoNeededArray = json["additional_info_needed"] as? NSArray {
                        for index in 0..<additionalInfoNeededArray.count {
                                if let additionalInfoNeededStr = additionalInfoNeededArray[index] as? String {
                                        additionalInfoNeeded.append(additionalInfoNeededStr)
                                    }
                            }
                    }
                paymentMethod.additionalInfoNeeded = additionalInfoNeeded

                if let accreditationTime = json["accreditation_time"] as? Int {
                        paymentMethod.accreditationTime = accreditationTime
                    }

                var financialInstitutions: [FinancialInstitution] = [FinancialInstitution]()

                if let financialInstitutionsArray = json["financial_institutions"] as? NSArray {
                       for index in 0..<financialInstitutionsArray.count {
                                if let financialInstitutionsDic = financialInstitutionsArray[index] as? NSDictionary {
                                        financialInstitutions.append(FinancialInstitution.fromJSON(financialInstitutionsDic))
                                    }
                            }
                    }

                paymentMethod.financialInstitutions = financialInstitutions.isEmpty ? nil : financialInstitutions

                return paymentMethod
            }

    open var isIssuerRequired: Bool {
        return isAdditionalInfoNeeded("issuer_id")
    }

    open var isIdentificationRequired: Bool {
        if isAdditionalInfoNeeded("cardholder_identification_number") || isAdditionalInfoNeeded("identification_number") || isEntityTypeRequired {
            return true
        }
        return false
    }
    open var isIdentificationTypeRequired: Bool {
        if isAdditionalInfoNeeded("cardholder_identification_type") || isAdditionalInfoNeeded("identification_type") || isEntityTypeRequired {
            return true
        }
        return false
    }

    open var isPayerInfoRequired: Bool {
        if isAdditionalInfoNeeded("bolbradesco_name") || isAdditionalInfoNeeded("bolbradesco_identification_type") || isAdditionalInfoNeeded("bolbradesco_identification_number") {
            return true
        }
        return false
    }

    open var isEntityTypeRequired: Bool {
        return isAdditionalInfoNeeded("entity_type")
    }

    open var isCard: Bool {
        if let paymentTypeId = PaymentTypeId(rawValue: self.paymentTypeId) {
            return paymentTypeId.isCard()
        }
        return false
    }

    open var isCreditCard: Bool {
        if let paymentTypeId = PaymentTypeId(rawValue: self.paymentTypeId) {
            return paymentTypeId.isCreditCard()
        }
        return false

    }

    open var isPrepaidCard: Bool {
        if let paymentTypeId = PaymentTypeId(rawValue: self.paymentTypeId) {
            return paymentTypeId.isPrepaidCard()
        }
        return false
    }

    open var isDebitCard: Bool {
        if let paymentTypeId = PaymentTypeId(rawValue: self.paymentTypeId) {
            return paymentTypeId.isDebitCard()
        }
        return false
    }

    open func isSecurityCodeRequired(_ bin: String) -> Bool {
        let settings: [Setting]? = Setting.getSettingByBin(self.settings, bin: bin)
        if let settings = settings {
            if settings[0].securityCode.length != 0 {
                return true
            }
        }
        return false
    }

    open func isAdditionalInfoNeeded(_ param: String!) -> Bool {
        if additionalInfoNeeded != nil && additionalInfoNeeded.count > 0 {
            for info in additionalInfoNeeded where info == param {
                return true
            }
        }
        return false
    }

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String: Any] {
        let id: Any = String.isNullOrEmpty(self.paymentMethodId) ?  JSONHandler.null : self.paymentMethodId!
        let name: Any = self.name == nil ?  JSONHandler.null : self.name
        let payment_type_id: Any = self.paymentTypeId == nil ? JSONHandler.null : self.paymentTypeId
        let status: Any = self.status == nil ? JSONHandler.null : self.status
        let secureThumbnail: Any = self.secureThumbnail == nil ? JSONHandler.null : self.secureThumbnail
        let thumbnail: Any = self.thumbnail == nil ? JSONHandler.null : self.thumbnail
        let deferredCapture: Any = self.deferredCapture == nil ? JSONHandler.null : self.deferredCapture
        let maxAllowedAmount: Any = self.maxAllowedAmount == nil ? JSONHandler.null : self.maxAllowedAmount
        let accreditationTime: Any = self.accreditationTime == nil ? JSONHandler.null : self.accreditationTime!

        var obj: [String: Any] = [
            "id": id,
            "name": name,
            "payment_type_id": payment_type_id,
            "status": status,
            "secure_thumbnail": secureThumbnail,
            "thumbnail": thumbnail,
            "deferred_capture": deferredCapture,
            "max_allowed_amount": maxAllowedAmount,
            "min_allowed_amount": self.minAllowedAmount,
            "accreditation_time": accreditationTime
        ]

        var additionalInfoJson = ""
        for info in self.additionalInfoNeeded {
            additionalInfoJson.append(info + ",")
        }
        obj["additional_info_needed"] = String(additionalInfoJson.dropLast())

        if Array.isNullOrEmpty(settings) {
            obj["settings"] = JSONHandler.null

        } else {
            var settingsJson: [[String: Any]] = []
            for setting in self.settings {
                settingsJson.append(setting.toJSON())
            }
            obj["settings"] = settingsJson
        }

        if Array.isNullOrEmpty(financialInstitutions) {
            obj["financial_institutions"] = JSONHandler.null

        } else {
            var financialInstitutionsJson: [[String: Any]] = []
            for financialInstitution in self.financialInstitutions {
                financialInstitutionsJson.append(financialInstitution.toJSON())
            }
            obj["financial_institutions"] = financialInstitutionsJson
        }

        if let merchantAccountID = self.merchantAccountId {
            obj["merchant_account_id"] = merchantAccountID
        }

        return obj

    }

    open func conformsToBIN(_ bin: String) -> Bool {
        return (Setting.getSettingByBin(self.settings, bin: bin) != nil)
    }
    open func cloneWithBIN(_ bin: String) -> PaymentMethod? {
        let paymentMethod: PaymentMethod = PaymentMethod()
        paymentMethod.paymentMethodId = self.paymentMethodId
        paymentMethod.name = self.name
        paymentMethod.paymentTypeId = self.paymentTypeId
        paymentMethod.additionalInfoNeeded = self.additionalInfoNeeded
        if(Setting.getSettingByBin(self.settings, bin: bin) != nil) {
            paymentMethod.settings = Setting.getSettingByBin(self.settings, bin: bin)!
            return paymentMethod
        } else {
            return nil
        }
    }

   open var isAmex: Bool {
        return self.paymentMethodId == "amex"
    }

   open var isAccountMoney: Bool {
        return self.paymentMethodId == PaymentTypeId.ACCOUNT_MONEY.rawValue
    }

    open func secCodeMandatory() -> Bool {
        if self.settings.count == 0 {
            return false // Si no tiene settings el codigo no es mandatorio
        }
        let filterList = self.settings.filter({ return $0.securityCode.mode == self.settings[0].securityCode.mode })
        if filterList.count == self.settings.count {
            return self.settings[0].securityCode.mode == "mandatory"
        } else {
            return true // si para alguna de sus settings es mandatorio entonces el codigo es mandatorio
        }
    }

    open func secCodeLenght(_ bin: String? = nil) -> Int {

        if let bin = bin {
            var binSettings: [Setting]? = nil
            binSettings = Setting.getSettingByBin(self.settings, bin: bin)
            if !Array.isNullOrEmpty(binSettings) {
                return binSettings![0].securityCode.length
            }
        }
        if self.settings != nil && !self.settings.isEmpty {
            return settings[0].securityCode.length
        }
        return 3
    }

    open func cardNumberLenght() -> Int {
        if self.settings.count == 0 {
            return 0 //Si no tiene settings la longitud es cero
        }
        let filterList = self.settings.filter({ return $0.cardNumber.length == self.settings[0].cardNumber.length })
        if filterList.count == self.settings.count {
            return self.settings[0].cardNumber.length
        } else {
            return 0 //si la longitud de sus numberos, en sus settings no es siempre la misma entonces responde 0
        }
    }

    open func secCodeInBack() -> Bool {
        if self.settings == nil || self.settings.count == 0 {
            return true //si no tiene settings, por defecto el codigo de seguridad ira atras
        }
        let filterList = self.settings.filter({ return $0.securityCode.cardLocation == self.settings[0].securityCode.cardLocation })
        if filterList.count == self.settings.count {
            return self.settings[0].securityCode.cardLocation == "back"
        } else {
            return true //si sus settings no coinciden el codigo ira atras por default
        }
    }

    open var isOnlinePaymentMethod: Bool {
        return self.isCard || self.isAccountMoney
    }

    open var isVISA: Bool {
        return ((self.paymentMethodId == "visa") && (self.paymentMethodId == "debvisa"))
    }
    open var isMASTERCARD: Bool {
        return ((self.paymentMethodId == "master") && (self.paymentMethodId == "debmaster"))
    }

    open func conformsPaymentPreferences(_ paymentPreference: PaymentPreference?) -> Bool {

        if paymentPreference == nil {
            return true
        }
        if paymentPreference!.defaultPaymentMethodId != nil {
            if self.paymentMethodId != paymentPreference!.defaultPaymentMethodId {
                return false
            }
        }
        if let excludedPaymentTypeIds = paymentPreference?.excludedPaymentTypeIds {
            for excludedPaymentType in excludedPaymentTypeIds where excludedPaymentType == self.paymentTypeId {
                return false
            }
        }

        if let excludedPaymentMethodIds = paymentPreference?.excludedPaymentMethodIds {
            for excludedPaymentMethodId  in excludedPaymentMethodIds where excludedPaymentMethodId == self.paymentMethodId {
                return false
            }
        }

        if paymentPreference!.defaultPaymentTypeId != nil {
            if paymentPreference!.defaultPaymentTypeId != self.paymentTypeId {
                return false
            }
        }

        return true
    }

    // IMAGE
    open func getImage() -> UIImage? {
        return MercadoPago.getImageFor(self)
    }

    open func setExternalPaymentMethodImage(externalImage: UIImage?) {
        if let imageResource = externalImage {
            externalPaymentPluginImageData = UIImagePNGRepresentation(imageResource) as NSData?
        }
    }

    open func getImageForExtenalPaymentMethod() -> UIImage? {
        if let imageDataStream = externalPaymentPluginImageData as Data? {
            return UIImage(data: imageDataStream)
        }
        return nil
    }

    // COLORS
    // First Color
    open func getColor(bin: String?) -> UIColor {
        var settings: [Setting]? = nil

        if let bin = bin {
            settings = Setting.getSettingByBin(self.settings, bin: bin)
        }

        return MercadoPago.getColorFor(self, settings: settings)
    }
    // Font Color
    open func getFontColor(bin: String?) -> UIColor {
        var settings: [Setting]? = nil

        if let bin = bin {
            settings = Setting.getSettingByBin(self.settings, bin: bin)
        }

        return MercadoPago.getFontColorFor(self, settings: settings)
    }
    // Edit Font Color
    open func getEditingFontColor(bin: String?) -> UIColor {
        var settings: [Setting]? = nil

        if let bin = bin {
            settings = Setting.getSettingByBin(self.settings, bin: bin)
        }

        return MercadoPago.getEditingFontColorFor(self, settings: settings)
    }

    // MASKS
    // Label Mask
    open func getLabelMask(bin: String?) -> String {
        var settings: [Setting]? = nil

        if let bin = bin {
            settings = Setting.getSettingByBin(self.settings, bin: bin)
        }
        return MercadoPago.getLabelMaskFor(self, settings: settings)
    }
    // Edit Text Mask
    open func getEditTextMask(bin: String?) -> String {
        var settings: [Setting]? = nil

        if let bin = bin {
            settings = Setting.getSettingByBin(self.settings, bin: bin)
        }
        return MercadoPago.getEditTextMaskFor(self, settings: settings)
    }

    var isBolbradesco: Bool {
        return self.paymentMethodId.contains(PaymentTypeId.BOLBRADESCO.rawValue)
    }
}
