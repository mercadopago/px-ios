//
//  PaymentMethodTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class PaymentMethodTest: BaseTest {

    func testIsIssuerRequired() {

    }

    func testToJSON() {
        let paymentMethod = MockBuilder.buildPaymentMethod("paymentMethodId", name: "name")
        paymentMethod.status = "active"
        paymentMethod.secureThumbnail = "secureThumbnail"
        paymentMethod.thumbnail = "thumbnail"
        paymentMethod.deferredCapture = "supported"
        paymentMethod.minAllowedAmount = 100
        paymentMethod.maxAllowedAmount = 20000
        paymentMethod.accreditationTime = 10

        let paymentMethodJson = paymentMethod.toJSON()

        XCTAssertNotNil(paymentMethod.toJSONString())

        XCTAssertEqual(paymentMethodJson["id"] as! String, "paymentMethodId")
        XCTAssertEqual(paymentMethodJson["name"] as! String, "name")
        XCTAssertEqual(paymentMethodJson["payment_type_id"] as! String, "credit_card")
        XCTAssertEqual(paymentMethodJson["status"] as! String, "active")
        XCTAssertEqual(paymentMethodJson["secure_thumbnail"] as! String, "secureThumbnail")
        XCTAssertEqual(paymentMethodJson["thumbnail"] as! String, "thumbnail")
        XCTAssertEqual(paymentMethodJson["deferred_capture"] as! String, "supported")
        XCTAssertEqual(paymentMethodJson["min_allowed_amount"] as! Double, 100)
        XCTAssertEqual(paymentMethodJson["max_allowed_amount"] as! Double, 20000)
        XCTAssertEqual(paymentMethodJson["accreditation_time"] as! Int, 10)

    }

    //Test for PaymentMethod First Color
    func testGetPMDefaultFirstColor() {
        let paymentMethod = MockBuilder.buildPaymentMethod("sarasa")

        let color = paymentMethod.getColor(bin: nil)
        XCTAssertEqual(color, UIColor.cardDefaultColor())
    }

    func testGetPMFirstColor() {
        let paymentMethod = MockBuilder.buildPaymentMethod("visa", name: "Visa", paymentTypeId: "credit_card", multipleSettings: false)
        let cardNumber = "4242424242424242"
        let bin = cardNumber.substring(to: (cardNumber.characters.index(cardNumber.startIndex, offsetBy: 6)))
        let color = paymentMethod.getColor(bin: bin)
        XCTAssertEqual(color, MercadoPago.getColorFor(paymentMethod, settings: nil))
    }

    func testGetPMFirstColorForMultipleSettings() {
        let paymentMethod = MockBuilder.buildPaymentMethod("maestro", name: "Maestro", paymentTypeId: "debit_card", multipleSettings: true)
        let firstSettingCardNumber = "501041456060594693"
        let secondSettingCardNumber = "5010811232093852985"
        let firstBin = firstSettingCardNumber.substring(to: (firstSettingCardNumber.characters.index(firstSettingCardNumber.startIndex, offsetBy: 6)))
        let secondBin = secondSettingCardNumber.substring(to: (secondSettingCardNumber.characters.index(firstSettingCardNumber.startIndex, offsetBy: 6)))

        let firstSetting: [Setting] = [paymentMethod.settings[0]]
        let secondSetting: [Setting] = [paymentMethod.settings[1]]

        let firstColor = paymentMethod.getColor(bin: firstBin)
        XCTAssertEqual(firstColor, MercadoPago.getColorFor(paymentMethod, settings: firstSetting))

        let secondColor = paymentMethod.getColor(bin: secondBin)
        XCTAssertEqual(secondColor, MercadoPago.getColorFor(paymentMethod, settings: secondSetting))
    }

    //Test for PaymentMethod Label Mask
    func testGetPMDefaultLabelMask() {
        let paymentMethod = MockBuilder.buildPaymentMethod("sarasa")

        let mask = paymentMethod.getLabelMask(bin: nil)
        XCTAssertEqual(mask, MercadoPago.getLabelMaskFor(paymentMethod, settings: nil))
    }

    func testGetPMLabelMask() {
        let paymentMethod = MockBuilder.buildPaymentMethod("visa", name: "Visa", paymentTypeId: "credit_card", multipleSettings: false)
        let cardNumber = "4242424242424242"
        let bin = cardNumber.substring(to: (cardNumber.characters.index(cardNumber.startIndex, offsetBy: 6)))
        let mask = paymentMethod.getLabelMask(bin: bin)
        XCTAssertEqual(mask, MercadoPago.getLabelMaskFor(paymentMethod, settings: nil))
    }

    func testGetPMLabelMaskForMultipleSettings() {
        let paymentMethod = MockBuilder.buildPaymentMethod("maestro", name: "Maestro", paymentTypeId: "debit_card", multipleSettings: true)
        let firstSettingCardNumber = "501041456060594693"
        let secondSettingCardNumber = "5010811232093852985"
        let firstBin = firstSettingCardNumber.substring(to: (firstSettingCardNumber.characters.index(firstSettingCardNumber.startIndex, offsetBy: 6)))
        let secondBin = secondSettingCardNumber.substring(to: (secondSettingCardNumber.characters.index(firstSettingCardNumber.startIndex, offsetBy: 6)))

        let firstSetting: [Setting] = [paymentMethod.settings[0]]
        let secondSetting: [Setting] = [paymentMethod.settings[1]]

        let firstMask = paymentMethod.getLabelMask(bin: firstBin)
        XCTAssertEqual(firstMask, MercadoPago.getLabelMaskFor(paymentMethod, settings: firstSetting))

        let secondMask = paymentMethod.getLabelMask(bin: secondBin)
        XCTAssertEqual(secondMask, MercadoPago.getLabelMaskFor(paymentMethod, settings: secondSetting))
    }

    //Test for PaymentMethod Edit Text Mask
    func testGetPMDefaultEditTextMask() {
        let paymentMethod = MockBuilder.buildPaymentMethod("sarasa")

        let mask = paymentMethod.getEditTextMask(bin: nil)
        XCTAssertEqual(mask, MercadoPago.getEditTextMaskFor(paymentMethod, settings: nil))
    }

    func testGetPMEditTextMask() {
        let paymentMethod = MockBuilder.buildPaymentMethod("visa", name: "Visa", paymentTypeId: "credit_card", multipleSettings: false)
        let cardNumber = "4242424242424242"
        let bin = cardNumber.substring(to: (cardNumber.characters.index(cardNumber.startIndex, offsetBy: 6)))
        let editTextMask = paymentMethod.getEditTextMask(bin: bin)
        XCTAssertEqual(editTextMask, MercadoPago.getEditTextMaskFor(paymentMethod, settings: nil))
    }

    func testGetPMEditTextMaskForMultipleSettings() {
        let paymentMethod = MockBuilder.buildPaymentMethod("maestro", name: "Maestro", paymentTypeId: "debit_card", multipleSettings: true)
        let firstSettingCardNumber = "501041456060594693"
        let secondSettingCardNumber = "5010811232093852985"
        let firstBin = firstSettingCardNumber.substring(to: (firstSettingCardNumber.characters.index(firstSettingCardNumber.startIndex, offsetBy: 6)))
        let secondBin = secondSettingCardNumber.substring(to: (secondSettingCardNumber.characters.index(firstSettingCardNumber.startIndex, offsetBy: 6)))

        let firstSetting: [Setting] = [paymentMethod.settings[0]]
        let secondSetting: [Setting] = [paymentMethod.settings[1]]

        let firstEditTextMask = paymentMethod.getEditTextMask(bin: firstBin)
        XCTAssertEqual(firstEditTextMask, MercadoPago.getEditTextMaskFor(paymentMethod, settings: firstSetting))

        let secondEditTextMask = paymentMethod.getEditTextMask(bin: secondBin)
        XCTAssertEqual(secondEditTextMask, MercadoPago.getEditTextMaskFor(paymentMethod, settings: secondSetting))
    }

    //Test for PaymentMethod Image
    func testGetPMImage() {
        let paymentMethod = MockBuilder.buildPaymentMethod("visa", name: "Visa", paymentTypeId: "credit_card", multipleSettings: false)
        let cardNumber = "4242424242424242"
        let bin = cardNumber.substring(to: (cardNumber.characters.index(cardNumber.startIndex, offsetBy: 6)))
        let image = paymentMethod.getImage()
        XCTAssertEqual(image, MercadoPago.getImageFor(paymentMethod))

    }

}
