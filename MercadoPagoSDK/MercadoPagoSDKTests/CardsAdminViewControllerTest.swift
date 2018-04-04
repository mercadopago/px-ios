//
//  CardsAdminViewControllerTest.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 6/9/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class CardsAdminViewControllerTest: BaseTest {

    let HEADER_SECTION_NUMBER = 0
    let CARDS_SECTION_NUMBER = 1

    var cardsAdminViewController: CardsAdminViewController!
    let dummyCard = [MockBuilder.buildCard()]
    let dummyCards = [MockBuilder.buildCard(), MockBuilder.buildCard()]

    let cardAdminViewModel = CardsAdminViewModel(cards: nil, extraOptionTitle: nil, confirmPromptText: nil)

    override func setUp() {
        super.setUp()
        cardsAdminViewController = CardsAdminViewController(viewModel: cardAdminViewModel, callback: { (_) in

        })
        _ = cardsAdminViewController.view
    }

    func testCanInstantiateViewController() {
        XCTAssertNotNil(cardsAdminViewController)
    }

    func testCollectionViewIsNotNilAfterViewDidLoad() {
        XCTAssertNotNil(cardsAdminViewController.collectionSearch)
    }

    func testShouldSetCollectionViewDataSource() {
        XCTAssertNotNil(cardsAdminViewController.collectionSearch.dataSource)
    }

    func testConformsToCollectionViewDataSource() {
        XCTAssert(CardsAdminViewController.conforms(to: UICollectionViewDataSource.self))
    }

    func testShouldSetCollectionViewDelegate() {
        XCTAssertNotNil(cardsAdminViewController.collectionSearch.delegate)
    }

    func testSConformsToCollectionViewDelegate() {
        XCTAssert(CardsAdminViewController.conforms(to: UICollectionViewDelegate.self))
    }

    func testNumberOfItems() {
        XCTAssertEqual(cardsAdminViewController.numberOfSections(in: cardsAdminViewController.collectionSearch), cardsAdminViewController.viewModel.numberOfSections())
    }

    func testNumberOfItemsInSection() {
        XCTAssertEqual(cardsAdminViewController.collectionView(cardsAdminViewController.collectionSearch, numberOfItemsInSection: HEADER_SECTION_NUMBER), cardsAdminViewController.viewModel.numberOfItemsInSection(section: HEADER_SECTION_NUMBER))

        XCTAssertEqual(cardsAdminViewController.collectionView(cardsAdminViewController.collectionSearch, numberOfItemsInSection: CARDS_SECTION_NUMBER), cardsAdminViewController.viewModel.numberOfItemsInSection(section: CARDS_SECTION_NUMBER))

        cardsAdminViewController.viewModel.cards = dummyCards

        XCTAssertEqual(cardsAdminViewController.collectionView(cardsAdminViewController.collectionSearch, numberOfItemsInSection: CARDS_SECTION_NUMBER), cardsAdminViewController.viewModel.numberOfItemsInSection(section: CARDS_SECTION_NUMBER))
    }

    func testInsetForSection() {
        XCTAssertEqual(cardsAdminViewController.collectionView(cardsAdminViewController.collectionSearch, layout: cardsAdminViewController.collectionSearch.collectionViewLayout, insetForSectionAt: HEADER_SECTION_NUMBER), UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        XCTAssertEqual(cardsAdminViewController.collectionView(cardsAdminViewController.collectionSearch, layout: cardsAdminViewController.collectionSearch.collectionViewLayout, insetForSectionAt: CARDS_SECTION_NUMBER), UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }

    func testMinimumLineSpacingForSectionAt() {
        XCTAssertEqual(cardsAdminViewController.collectionView(cardsAdminViewController.collectionSearch, layout: cardsAdminViewController.collectionSearch.collectionViewLayout, minimumLineSpacingForSectionAt: HEADER_SECTION_NUMBER), 8)
        XCTAssertEqual(cardsAdminViewController.collectionView(cardsAdminViewController.collectionSearch, layout: cardsAdminViewController.collectionSearch.collectionViewLayout, minimumLineSpacingForSectionAt: CARDS_SECTION_NUMBER), 8)
    }

    func testCallbackCancel() {
        XCTAssertNotNil(cardsAdminViewController.callbackCancel)
    }
}
