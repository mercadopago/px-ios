//
//  CheckoutPreferenceTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 21/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class CheckoutPreferenceTest: XCTestCase {

    var preference: CheckoutPreference?

    override func setUp() {
        super.setUp()
        self.preference = MockBuilder.buildCheckoutPreference()
    }

    func testGetAmount() {
        preference?.items?.removeAll()
        XCTAssertEqual(preference?.getAmount(), 0)

        let item1 = Item(itemId: "id1", title: "item 1 title", quantity: 1, unitPrice: 10)
        let item2 = Item(itemId: "id2", title: "item 2 title", quantity: 3, unitPrice: 5)
        let item3 = Item(itemId: "id3", title: "item 3 title", quantity: 2, unitPrice: 2)
        self.preference!.items = [item1, item2, item3]

        XCTAssertEqual(preference?.getAmount(), 29)
        preference?.items?.remove(at: 1)
        XCTAssertEqual(preference?.getAmount(), 14)

    }

    func testAddItem() {
        let checkoutPreference = CheckoutPreference()
        let item1 = Item(itemId: "id1", title: "item 1 title", quantity: 1, unitPrice: 10)
        checkoutPreference.addItem(item: item1)
        XCTAssertEqual(checkoutPreference.getItems()![0], item1)
    }

    func testAddItems() {
        let checkoutPreference = CheckoutPreference()
        var items = [Item]()
        let item1 = Item(itemId: "id1", title: "item 1 title", quantity: 1, unitPrice: 10)
        let item2 = Item(itemId: "id2", title: "item 2 title", quantity: 3, unitPrice: 5)
        items.append(item1)
        items.append(item2)
        checkoutPreference.addItems(items: items)
        XCTAssertEqual(checkoutPreference.getItems()?[0], item1)
        XCTAssertEqual(checkoutPreference.getItems()?[1], item2)
    }

    func testSetMaxInstallments() {
        let checkoutPreference = CheckoutPreference()
        XCTAssertEqual(checkoutPreference.getMaxAcceptedInstallments(), 0)
        checkoutPreference.setMaxInstallments(5)
        XCTAssertEqual(checkoutPreference.getMaxAcceptedInstallments(), 5)
    }

    func testSetDefaultInstallments() {
        let checkoutPreference = CheckoutPreference()
        XCTAssertEqual(checkoutPreference.getDefaultInstallments(), 0)
        checkoutPreference.setDefaultInstallments(5)
        XCTAssertEqual(checkoutPreference.getDefaultInstallments(), 5)
    }

    func testAddExcludedPaymentTypes() {
        let checkoutPreference = CheckoutPreference()
        XCTAssertEqual(checkoutPreference.getExcludedPaymentTypesIds(), nil)
        checkoutPreference.setExcludedPaymentTypes(["credit_card"])
        XCTAssertEqual(checkoutPreference.getExcludedPaymentTypesIds(), ["credit_card"])
    }

    func testAddExcludedPaymentType() {
        let checkoutPreference = CheckoutPreference()
        XCTAssertEqual(checkoutPreference.getExcludedPaymentTypesIds(), nil)
        checkoutPreference.addExcludedPaymentType("credit_card")
        XCTAssertEqual(checkoutPreference.getExcludedPaymentTypesIds(), ["credit_card"])
        checkoutPreference.addExcludedPaymentType("debit_card")
        XCTAssertEqual(checkoutPreference.getExcludedPaymentTypesIds(), ["debit_card", "credit_card"])
    }

    func testAddExcludedPaymentMethods() {
        let checkoutPreference = CheckoutPreference()
        XCTAssertEqual(checkoutPreference.getExcludedPaymentMethodsIds(), nil)
        checkoutPreference.setExcludedPaymentMethods(["credit_card"])
        XCTAssertEqual(checkoutPreference.getExcludedPaymentMethodsIds(), ["credit_card"])
    }

    func testAddExcludedPaymentMethod() {
        let checkoutPreference = CheckoutPreference()
        XCTAssertEqual(checkoutPreference.getExcludedPaymentMethodsIds(), nil)
        checkoutPreference.addExcludedPaymentMethod("credit_card")
        XCTAssertEqual(checkoutPreference.getExcludedPaymentMethodsIds(), ["credit_card"])
        checkoutPreference.addExcludedPaymentMethod("debit_card")
        XCTAssertEqual(checkoutPreference.getExcludedPaymentMethodsIds(), ["debit_card", "credit_card"])
    }

    func testSetDefaultPaymentMethodId() {
        let checkoutPreference = CheckoutPreference()
        checkoutPreference.setDefaultPaymentMethodId("visa")
        XCTAssertEqual(checkoutPreference.getDefaultPaymentMethodId(), "visa")
    }

    func testSetPayerEmail() {
        let checkoutPreference = CheckoutPreference()
        checkoutPreference.setPayerEmail("sarasa@hotmail.com")
        XCTAssertEqual(checkoutPreference.getPayer().email, "sarasa@hotmail.com")
    }

    func testSetSite() {
        let checkoutPreference = CheckoutPreference()
        checkoutPreference.setSite(siteId: "MLA")
        XCTAssertEqual(checkoutPreference.getSiteId(), "MLA")
    }

    func testSetID() {
        let checkoutPreference = CheckoutPreference()
        checkoutPreference.setId("id")
        XCTAssertEqual(checkoutPreference.getId(), "id")
    }

    func testSetExpirationDate() {
        let checkoutPreference = CheckoutPreference()
        let date = Date()
        checkoutPreference.setExpirationDate(date)
        XCTAssertEqual(checkoutPreference.getExpirationDate(), date)
    }
    func testSetActiveFromDate() {
        let checkoutPreference = CheckoutPreference()
        let date = Date()
        checkoutPreference.setActiveFromDate(date)
        XCTAssertEqual(checkoutPreference.getActiveFromDate(), date)
    }

    func testIsExpired() {
        let checkoutPreference = CheckoutPreference()
        XCTAssertFalse(checkoutPreference.isExpired())
        var date = Date(timeIntervalSinceNow: TimeInterval(200.0))
        checkoutPreference.setExpirationDate(date)
        XCTAssert(checkoutPreference.isExpired())
        date = Date(timeIntervalSinceReferenceDate: TimeInterval(200.0))
        checkoutPreference.setExpirationDate(date)
        XCTAssertFalse(checkoutPreference.isExpired())
    }

    func testIsActive() {
        let checkoutPreference = CheckoutPreference()
        XCTAssert(checkoutPreference.isActive())
        var date = Date(timeIntervalSinceNow: TimeInterval(200.0))
        checkoutPreference.setActiveFromDate(date)
        XCTAssertFalse(checkoutPreference.isActive())
        date = Date(timeIntervalSinceReferenceDate: TimeInterval(200.0))
        checkoutPreference.setActiveFromDate(date)
        XCTAssert(checkoutPreference.isActive())
    }

    func testIsItemValid() {
        var checkoutPreference = CheckoutPreference()
        XCTAssertEqual(checkoutPreference.itemsValid(), "No hay items")

        var item1 = Item(itemId: "id1", title: "item 1 title", quantity: 0, unitPrice: 10)
        checkoutPreference.addItems(items: [item1])
        XCTAssertEqual(checkoutPreference.itemsValid(), "La cantidad de items no es valida")

        checkoutPreference = CheckoutPreference()
        item1 = Item(itemId: "id1", title: "item 1 title", quantity: 1, unitPrice: 10)
        let item2 = Item(itemId: "id2", title: "item 2 title", quantity: 3, unitPrice: 5, currencyId: "MXN")
        checkoutPreference.addItems(items: [item1, item2])
        XCTAssertEqual(checkoutPreference.itemsValid(), "Los items tienen diferente moneda")
    }

    func testValidateMissingPayer() {
        let checkoutPreference = CheckoutPreference()
        let item1 = Item(itemId: "id1", title: "item 1 title", quantity: 1, unitPrice: 10)
        let item2 = Item(itemId: "id2", title: "item 2 title", quantity: 3, unitPrice: 5)
        checkoutPreference.addItems(items: [item1, item2])
        XCTAssertEqual(checkoutPreference.validate(), "Se requiere email de comprador")
    }

    func testValidateGreaterThanZeroAmount() {
        let checkoutPreference = CheckoutPreference()
        let item1 = Item(itemId: "id1", title: "item 1 title", quantity: 1, unitPrice: 10)
        let item2 = Item(itemId: "id2", title: "item 2 title", quantity: 3, unitPrice: -5)
        checkoutPreference.addItems(items: [item1, item2])
        checkoutPreference.payer = Payer()
        checkoutPreference.setPayerEmail("payerem@il.com")
        XCTAssertEqual(checkoutPreference.validate(), "El monto de la compra no es válido")
    }

    func testValidateGreaterThanZeroAmount_OneItem() {
        let checkoutPreference = CheckoutPreference()
        let item1 = Item(itemId: "id1", title: "item 1 title", quantity: 4, unitPrice: -2)
        checkoutPreference.addItems(items: [item1])
        checkoutPreference.payer = Payer()
        checkoutPreference.setPayerEmail("payerem@il.com")
        XCTAssertEqual(checkoutPreference.validate(), "El monto de la compra no es válido")
    }

}
