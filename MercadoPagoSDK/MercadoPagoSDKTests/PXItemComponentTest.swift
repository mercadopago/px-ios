//
//  PXItemComponentTest.swift
//  MercadoPagoSDKTests
//
//  Created by Eden Torres on 3/6/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import XCTest

class PXItemComponentTest: BaseTest {

    // MARK: One item tests
    func testItemView_oneItem_render() {
        // Given
        let item = MockBuilder.buildItem("id", quantity: 1, unitPrice: 1, description: "d")
        let reviewViewModel = ReviewMockComponentHelper.buildResultViewModelWithPreference(items: [item])

        // When
        let itemViews = ReviewMockComponentHelper.buildItemComponentView(reviewViewModel: reviewViewModel)

        // Then
        XCTAssertEqual(itemViews.count, 1)
        XCTAssertEqual(itemViews[0].itemTitle?.text, item.itemDescription)
        XCTAssertNil(itemViews[0].itemDescription)
        XCTAssertNil(itemViews[0].itemQuantity)
        XCTAssertNil(itemViews[0].itemAmount)
        XCTAssertNotNil(itemViews[0].itemImage)
    }

    func testItemView_oneItemWithQuantity_render() {
        // Given
        let item = MockBuilder.buildItem("id", quantity: 2, unitPrice: 1, description: "d")
        let reviewViewModel = ReviewMockComponentHelper.buildResultViewModelWithPreference(items: [item])

        // When
        let itemViews = ReviewMockComponentHelper.buildItemComponentView(reviewViewModel: reviewViewModel)

        // Then
        XCTAssertEqual(itemViews.count, 1)
        XCTAssertEqual(itemViews[0].itemTitle?.text, item.itemDescription)
        XCTAssertNil(itemViews[0].itemDescription)
        XCTAssertNotNil(itemViews[0].itemQuantity)
        XCTAssertNotNil(itemViews[0].itemAmount)
        XCTAssertNotNil(itemViews[0].itemImage)
    }

    func testItemView_oneItemWithNoDesciptionAndMultipleQuantity_render() {
        // Given
        let item = MockBuilder.buildItem("id", quantity: 2, unitPrice: 1, description: "")
        let reviewViewModel = ReviewMockComponentHelper.buildResultViewModelWithPreference(items: [item])

        // When
        let itemViews = ReviewMockComponentHelper.buildItemComponentView(reviewViewModel: reviewViewModel)

        // Then
        XCTAssertEqual(itemViews.count, 1)
    }

    func testItemView_oneItemWithNoDesciptionAndOneQuantity_render() {
        // Given
        let item = MockBuilder.buildItem("id", quantity: 1, unitPrice: 1, description: "")
        let reviewViewModel = ReviewMockComponentHelper.buildResultViewModelWithPreference(items: [item])

        // When
        let itemViews = ReviewMockComponentHelper.buildItemComponentView(reviewViewModel: reviewViewModel)

        // Then
        XCTAssertEqual(itemViews.count, 0)
    }

    func testItemView_oneItemWithItemsDisable_render() {
        // Given
        let item = MockBuilder.buildItem("id", quantity: 2, unitPrice: 1, description: "description")
        let reviewScreenPreference = ReviewScreenPreference()
        reviewScreenPreference.disableItems()
        let reviewViewModel = ReviewMockComponentHelper.buildResultViewModelWithPreference(items: [item], reviewScreenPreference: reviewScreenPreference)

        // When
        let itemViews = ReviewMockComponentHelper.buildItemComponentView(reviewViewModel: reviewViewModel)

        // Then
        XCTAssertEqual(itemViews.count, 0)
    }

    // MARK: More than one item tests
    func testItemView_twoItem_render() {
        // Given
        let item = MockBuilder.buildItem("id", quantity: 1, unitPrice: 1, description: "d")
        let item2 = MockBuilder.buildItem("id", quantity: 1, unitPrice: 1, description: "d")
        let reviewViewModel = ReviewMockComponentHelper.buildResultViewModelWithPreference(items: [item, item2])

        // When
        let itemViews = ReviewMockComponentHelper.buildItemComponentView(reviewViewModel: reviewViewModel)

        // Then
        XCTAssertEqual(itemViews.count, 2)
        XCTAssertEqual(itemViews[0].itemTitle?.text, "item title")
        XCTAssertEqual(itemViews[0].itemDescription?.text, item.itemDescription)
        XCTAssertNil(itemViews[0].itemQuantity)
        XCTAssertNotNil(itemViews[0].itemAmount)
        XCTAssertNotNil(itemViews[0].itemImage)

        XCTAssertEqual(itemViews[0].itemTitle?.text, "item title")
        XCTAssertEqual(itemViews[1].itemDescription?.text, item.itemDescription)
        XCTAssertNil(itemViews[1].itemQuantity)
        XCTAssertNotNil(itemViews[1].itemAmount)
        XCTAssertNotNil(itemViews[1].itemImage)
    }

    func testItemView_twoItemOneWithQuantity_render() {
        // Given
        let item = MockBuilder.buildItem("id", quantity: 2, unitPrice: 1, description: "d")
        let item2 = MockBuilder.buildItem("id", quantity: 1, unitPrice: 1, description: "d")
        let reviewViewModel = ReviewMockComponentHelper.buildResultViewModelWithPreference(items: [item, item2])

        // When
        let itemViews = ReviewMockComponentHelper.buildItemComponentView(reviewViewModel: reviewViewModel)

        // Then
        XCTAssertEqual(itemViews.count, 2)
        XCTAssertEqual(itemViews[0].itemTitle?.text, "item title")
        XCTAssertEqual(itemViews[0].itemDescription?.text, item.itemDescription)
        XCTAssertNotNil(itemViews[0].itemQuantity)
        XCTAssertNotNil(itemViews[0].itemAmount)
        XCTAssertNotNil(itemViews[0].itemImage)

        XCTAssertEqual(itemViews[0].itemTitle?.text, "item title")
        XCTAssertEqual(itemViews[1].itemDescription?.text, item.itemDescription)
        XCTAssertNil(itemViews[1].itemQuantity)
        XCTAssertNotNil(itemViews[1].itemAmount)
        XCTAssertNotNil(itemViews[1].itemImage)
    }

    func testItemView_twoItemNoDesciption_render() {
        // Given
        let item = MockBuilder.buildItem("id", quantity: 1, unitPrice: 1, description: "")
        let item2 = MockBuilder.buildItem("id", quantity: 1, unitPrice: 1, description: "d")
        let reviewViewModel = ReviewMockComponentHelper.buildResultViewModelWithPreference(items: [item, item2])

        // When
        let itemViews = ReviewMockComponentHelper.buildItemComponentView(reviewViewModel: reviewViewModel)

        // Then
        XCTAssertEqual(itemViews.count, 2)
        XCTAssertEqual(itemViews[0].itemTitle?.text, "item title")
        XCTAssertEqual(itemViews[0].itemDescription?.text, item.itemDescription)
        XCTAssertNotNil(itemViews[0].itemAmount)
        XCTAssertNotNil(itemViews[0].itemImage)

        XCTAssertEqual(itemViews[1].itemTitle?.text, "item title")
        XCTAssertNil(itemViews[1].itemQuantity)
        XCTAssertNil(itemViews[1].itemQuantity)
        XCTAssertNotNil(itemViews[1].itemAmount)
        XCTAssertNotNil(itemViews[1].itemImage)
    }
}
