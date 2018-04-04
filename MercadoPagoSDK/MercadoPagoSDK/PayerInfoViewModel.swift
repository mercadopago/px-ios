//
//  PayerInfoViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/29/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

public enum PayerInfoFlowStep: String {

    case CANCEL
    case SCREEN_IDENTIFICATION
    // For CNPJ: case SCREEN_LEGAL_NAME
    case SCREEN_NAME
    case SCREEN_LAST_NAME
    case SCREEN_ERROR
    case FINISH

}

class PayerInfoViewModel: NSObject {
    var identificationTypes: [IdentificationType]!
    var masks: [TextMaskFormater]!
    var currentMask: TextMaskFormater?

    var name: String = ""
    var lastName: String = ""
    var identificationNumber: String = ""
    let payer: Payer!

    var identificationType: IdentificationType!

    var currentStep: PayerInfoFlowStep = PayerInfoFlowStep.SCREEN_IDENTIFICATION

    init(identificationTypes: [IdentificationType], payer: Payer) {
        self.payer = payer
        super.init()

        self.identificationTypes = filterSupported(identificationTypes: identificationTypes)

        if identificationTypes.isEmpty {
            fatalError("No valid identification types for PayerInfo View Controller")
        }
        self.identificationType = identificationTypes[0]
        self.masks = getIdMask(IDtype: self.identificationType)
        self.currentMask = masks[0]
    }

    func filterSupported(identificationTypes: [IdentificationType]) -> [IdentificationType] {
        let supportedIdentificationTypes = identificationTypes.filter {$0.identificationTypeId == "CPF"}
        return supportedIdentificationTypes
    }

    func getDropdownOptions() -> [String] {
        var options: [String] = []
        for identificationType in self.identificationTypes {
            options.append(identificationType.identificationTypeId!)
        }
        return options
    }

     func getNextStep() -> PayerInfoFlowStep {
        switch currentStep {
        case .SCREEN_IDENTIFICATION:
            currentStep = .SCREEN_NAME
        case .SCREEN_NAME:
            currentStep = .SCREEN_LAST_NAME
        case .SCREEN_LAST_NAME:
            return .FINISH
        default:
            return .CANCEL
        }
        return currentStep
    }

     func getPreviousStep() -> PayerInfoFlowStep {
        switch currentStep {
        case .SCREEN_IDENTIFICATION:
            return .CANCEL
        case .SCREEN_NAME:
            currentStep = .SCREEN_IDENTIFICATION
        case .SCREEN_LAST_NAME:
            currentStep = .SCREEN_NAME
        default:
            return .CANCEL
        }
        return currentStep
    }

     func validateCurrentStep() -> Bool {
        switch currentStep {
        case .SCREEN_IDENTIFICATION:
            return validateIdentificationNumber()
        case .SCREEN_NAME:
            return validateName()
        case .SCREEN_LAST_NAME:
            return validateLastName()
        default:
            return true
        }
    }

    fileprivate func validateName() -> Bool {
        return !String.isNullOrEmpty(name)
    }

    fileprivate func validateLastName() -> Bool {
        return !String.isNullOrEmpty(lastName)
    }

    fileprivate func validateIdentificationNumber() -> Bool {
        let length = currentMask?.textUnmasked(identificationNumber).count
        return identificationType.minLength <= length! &&  length! <= identificationType.maxLength
    }

    func update(name: String) {
        self.name = name
    }

    func update(lastName: String) {
        self.lastName = lastName
    }

    func update(identificationNumber: String) {
        let maskedText = currentMask?.textMasked(identificationNumber, remasked: true)
        self.identificationNumber = (currentMask?.textUnmasked(maskedText))!
    }

    func getFullName() -> String {
        if String.isNullOrEmpty(name) && String.isNullOrEmpty(lastName) {
            return ""
        } else {
            return self.name.uppercased() + " " + self.lastName.uppercased()
        }
    }

    func getMaskedNumber(completeEmptySpaces: Bool = false) -> String {
        guard let mask = self.currentMask else {
            return ""
        }
        if completeEmptySpaces {
            let maskComplete = TextMaskFormater(mask: mask.mask, completeEmptySpaces: true, leftToRight: true, completeEmptySpacesWith: "*")
            return maskComplete.textMasked(self.identificationNumber, remasked: true)
        } else {
            return mask.textMasked(self.identificationNumber, remasked: true)
        }
    }

    func getFinalPayer() -> Payer {
        let identification = Identification(identificationType: identificationType, identificationNumber: identificationNumber)
        self.payer.identification = identification
        self.payer.name = name
        self.payer.surname = lastName

        return payer
    }

    fileprivate func maskFinder(dictID: String, forKey: String) -> [TextMaskFormater]? {
        let path = MercadoPago.getBundle()!.path(forResource: "IdentificationTypes", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: path!)

        if let IDtype = dictionary?.value(forKey: dictID) as? NSDictionary {
            if let mask = IDtype.value(forKey: forKey) as? String, mask != ""{
                let customInitialMask = TextMaskFormater(mask: mask, completeEmptySpaces: false, leftToRight: false)
                let customMask = TextMaskFormater(mask: mask, completeEmptySpaces: false, leftToRight: false, completeEmptySpacesWith: " ")
                return[customInitialMask, customMask]
            }
        }
        return nil
    }

    fileprivate func getIdMask(IDtype: IdentificationType?) -> [TextMaskFormater] {
        let site = MercadoPagoContext.getSite()
        let defaultInitialMask = TextMaskFormater(mask: "XXX.XXX.XXX.XXX", completeEmptySpaces: false, leftToRight: false)
        let defaultMask = TextMaskFormater(mask: "XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX", completeEmptySpaces: false, leftToRight: false)

        if IDtype != nil {
            if let masks = maskFinder(dictID: site+"_"+(IDtype?.identificationTypeId)!, forKey: "identification_mask") {
                return masks
            } else if let masks = maskFinder(dictID: site, forKey: "identification_mask") {
                return masks
            } else {
                return [defaultInitialMask, defaultMask]
            }
        } else {
            return [defaultInitialMask, defaultMask]
        }
    }
}
