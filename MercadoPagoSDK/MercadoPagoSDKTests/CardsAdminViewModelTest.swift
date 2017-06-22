//
//  CardsAdminViewModelTest.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 4/18/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class CardsAdminViewModelTest: BaseTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    let HEADER_SECTION_NUMBER = 0
    let CARDS_SECTION_NUMBER = 1
    let HEADER_ROW = 0

    let FIRST_ITEM_OPTION_ROW = 0
    let SECOND_ITEM_OPTION_ROW = 1
    let THIRD_ITEM_OPTION_ROW = 2

    func testNumberOfItemsToShow() {
        let dummyCards = [Card(), Card(), Card()]
        let cardAdminViewModel = CardsAdminViewModel(cards: dummyCards)
        XCTAssertEqual(cardAdminViewModel.numberOfOptions(), 3, "La cantidad de items a mostrar no se calcula correctametne.(Cantidad de tarjeas) ")
        XCTAssertFalse(cardAdminViewModel.shouldGetCustomerCardsInfo(), "No debería necesitar hacer la consulta de cards, dado que se instancia el ViewController con dichas tarjetas.")
        let cardAdminViewModelWithExtraOption = CardsAdminViewModel(cards: dummyCards, extraOptionTitle: "Extra Option")
        XCTAssertEqual(cardAdminViewModelWithExtraOption.numberOfOptions(), 4, "La cantidad de items a mostrar no se calcula correctametne. (Cantidad de tarjeas y una opcion extra)")
    }

    func testHeights() { // Solo funciona con el emulador en iPhone SE
        let json: NSDictionary = MockManager.getMockFor("Card")!
        let cardFromJSON = Card.fromJSON(json)
        let dummyCards = [cardFromJSON]
        let cardAdminViewModel = CardsAdminViewModel(cards: dummyCards)
        XCTAssertEqual(cardAdminViewModel.calculateHeight(indexPath: IndexPath(row: HEADER_ROW, section: HEADER_SECTION_NUMBER), numberOfCells: 1), 150.50)
        XCTAssertEqual(cardAdminViewModel.calculateHeight(indexPath: IndexPath(row: FIRST_ITEM_OPTION_ROW, section: CARDS_SECTION_NUMBER), numberOfCells: CARDS_SECTION_NUMBER), 150.50)
        XCTAssertEqual(cardAdminViewModel.maxHegithRow(indexPath:  IndexPath(row: HEADER_ROW, section: HEADER_SECTION_NUMBER)), 150.50)
        XCTAssertEqual(cardAdminViewModel.maxHegithRow(indexPath:  IndexPath(row: FIRST_ITEM_OPTION_ROW, section: CARDS_SECTION_NUMBER)), 150.50)
    }

    func testSectionsNumbers() {
        let dummyCards = [Card(), Card(), Card()]
        let cardAdminViewModel = CardsAdminViewModel(cards: dummyCards)
        XCTAssertTrue(cardAdminViewModel.isHeaderSection(section: 0))
        XCTAssertTrue(cardAdminViewModel.isCardsSection(section: 1))

    }

    func testNumbersOfSectionsAndOptions() {
        let dummyCards = [Card(), Card(), Card()]
        let cardAdminViewModel = CardsAdminViewModel(cards: dummyCards)
        cardAdminViewModel.loadingCards  = true
        XCTAssertEqual(cardAdminViewModel.numberOfSections(), 0)
        cardAdminViewModel.loadingCards  = false
        XCTAssertEqual(cardAdminViewModel.numberOfSections(), 2)
        XCTAssertEqual(cardAdminViewModel.numberOfItemsInSection(section: HEADER_SECTION_NUMBER), 1)
        XCTAssertEqual(cardAdminViewModel.numberOfItemsInSection(section: CARDS_SECTION_NUMBER), 3)
    }

//    func testSizeOfItems() {
//        let json : NSDictionary = MockManager.getMockFor("Card")!
//        let cardFromJSON = Card.fromJSON(json)
//        let dummyCards = [cardFromJSON]
//        let cardAdminViewModel = CardsAdminViewModel(cards: dummyCards)
//        XCTAssertEqual(cardAdminViewModel.sizeForItemAt(indexPath: IndexPath(row: HEADER_ROW, section: HEADER_SECTION_NUMBER)), CGSize(width:  375.0, height: 82.0))
//        XCTAssertEqual(cardAdminViewModel.sizeForItemAt(indexPath: IndexPath(row: FIRST_ITEM_OPTION_ROW, section: CARDS_SECTION_NUMBER)), CGSize(width: 171.5, height: 150.5))
//    }

    func testItemsForIndexPath() {
        let json: NSDictionary = MockManager.getMockFor("Card")!
        let cardFromJSON = Card.fromJSON(json)
        let dummyCards = [cardFromJSON]
        let cardAdminViewModel = CardsAdminViewModel(cards: dummyCards, extraOptionTitle : "Opcion Extra")
        XCTAssertTrue(cardAdminViewModel.isExtraOptionItemFor(indexPath: IndexPath(row: SECOND_ITEM_OPTION_ROW, section: CARDS_SECTION_NUMBER)))
        XCTAssertTrue(cardAdminViewModel.isCardItemFor(indexPath: IndexPath(row: FIRST_ITEM_OPTION_ROW, section: CARDS_SECTION_NUMBER)))
    }

}
