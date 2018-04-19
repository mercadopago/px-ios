//
//  PreferencePaymentMethods.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 12/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func <= <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

@objcMembers open class PaymentPreference: NSObject {

    open var excludedPaymentMethodIds: Set<String>?
    open var excludedPaymentTypeIds: Set<String>?
    open var defaultPaymentMethodId: String?
    open var maxAcceptedInstallments: Int = 0
    open var defaultInstallments: Int = 0
    var defaultPaymentTypeId: String?

    //installments = sea mayor a cero y que el defaults_istallment sea mayor a 0
    // excluded_payment_method < payment_methods
    //excluded_payment_types < payment_types

    public override init() {
        super.init()
    }

    open class func fromJSON(_ json: NSDictionary) -> PaymentPreference {
               let preferencePaymentMethods = PaymentPreference()

               var excludedPaymentMethods = Set<String>()
                if let pmArray = json["excluded_payment_methods"] as? NSArray {
                       for i in 0..<pmArray.count {
                                if let pmDic = pmArray[i] as? NSDictionary {
                                        let pmDicValue = pmDic.value(forKey: "id") as? String
                                        if pmDicValue != nil && pmDicValue!.count > 0 {
                                                excludedPaymentMethods.insert(pmDicValue!)
                                            }
                                    }
                           }
                        preferencePaymentMethods.excludedPaymentMethodIds = excludedPaymentMethods
                    }

                var excludedPaymentTypesIds = Set<String>()
                if let ptArray = json["excluded_payment_types"] as? NSArray {
                        for i in 0..<ptArray.count {
                                if let ptDic = ptArray[i] as? NSDictionary {
                                        let ptDicValue = ptDic.value(forKey: "id") as? String
                                        if ptDicValue != nil && ptDicValue?.count > 0 {
                                                excludedPaymentTypesIds.insert(ptDicValue!)
                                            }
                                    }
                            }
                        preferencePaymentMethods.excludedPaymentTypeIds = Set<String>(excludedPaymentTypesIds)
                    }

                if let defaultPaymentMethodId = JSONHandler.attemptParseToString(json["default_payment_method_id"]) {
                        preferencePaymentMethods.defaultPaymentMethodId = defaultPaymentMethodId
                    }
                if let maxAcceptedInstallments = JSONHandler.attemptParseToInt(json["installments"]) {
                        preferencePaymentMethods.maxAcceptedInstallments = maxAcceptedInstallments
                    }
                if let defaultInstallments = JSONHandler.attemptParseToInt(json["default_installments"]) {
                        preferencePaymentMethods.defaultInstallments = defaultInstallments
                    }

                return preferencePaymentMethods
            }

    open func autoSelectPayerCost(_ payerCostList: [PayerCost]) -> PayerCost? {
        if payerCostList.count == 0 {
            return nil
        }
        if payerCostList.count == 1 {
            return payerCostList.first
        }

            for payercost in payerCostList where payercost.installments == defaultInstallments {
                return payercost
            }

        if (payerCostList.first?.installments <= maxAcceptedInstallments)
            && (payerCostList[1].installments > maxAcceptedInstallments) {
                return payerCostList.first
        } else {
            return nil
        }

    }

    open func validate() -> Bool {
        if maxAcceptedInstallments <= 0 {
            return false
        }
        if PaymentType.allPaymentIDs.count <= excludedPaymentTypeIds?.count {
            return false
        }

        return true
    }

    open func getExcludedPaymentTypesIds() -> Set<String>? {
        if excludedPaymentTypeIds != nil {
            return excludedPaymentTypeIds
        }
        return nil
    }

    open func getDefaultInstallments() -> Int {
        if defaultInstallments > 0 {
            return defaultInstallments
        }
        return 0
    }

    open func getMaxAcceptedInstallments() -> Int {
        if maxAcceptedInstallments > 0 {
            return maxAcceptedInstallments
        }
        return 0
    }

    open func getExcludedPaymentMethodsIds() -> Set<String>? {
        if excludedPaymentMethodIds != nil {
            return excludedPaymentMethodIds
        }
        return nil
    }

    open func getDefaultPaymentMethodId() -> String? {
        if defaultPaymentMethodId != nil && defaultPaymentMethodId!.isNotEmpty {
            return defaultPaymentMethodId
        }
        return nil
    }

    open func addSettings(_ defaultPaymentTypeId: String? = nil, excludedPaymentMethodsIds: Set<String>? = nil, excludedPaymentTypesIds: Set<String>? = nil, defaultPaymentMethodId: String? = nil, maxAcceptedInstallment: Int? = nil, defaultInstallments: Int? = nil) -> PaymentPreference {

        if excludedPaymentMethodsIds != nil {
           self.excludedPaymentMethodIds =  excludedPaymentMethodsIds
        }

        if excludedPaymentTypesIds != nil {
            self.excludedPaymentTypeIds = excludedPaymentTypesIds
        }

        if defaultPaymentMethodId != nil {
             self.defaultPaymentMethodId = defaultPaymentMethodId
        }

        if maxAcceptedInstallment != nil {
            self.maxAcceptedInstallments = maxAcceptedInstallment!
        }

        if defaultInstallments != nil {
            self.defaultInstallments = defaultInstallments!
        }

        if defaultPaymentTypeId != nil {
            self.defaultPaymentTypeId = defaultPaymentTypeId
        }

        return self
    }
}
