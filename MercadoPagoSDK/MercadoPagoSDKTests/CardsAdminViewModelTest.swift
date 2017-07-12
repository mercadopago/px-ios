//
//  CardsAdminViewModelTest.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 4/18/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class CardsAdminViewModelTest: BaseTest {

    let HEADER_SECTION_NUMBER = 0
    let CARDS_SECTION_NUMBER = 1
    let HEADER_ROW = 0

    let FIRST_ITEM_OPTION_ROW = 0
    let SECOND_ITEM_OPTION_ROW = 1
    let THIRD_ITEM_OPTION_ROW = 2

    let dummyCard = [MockBuilder.buildCard()]
    let dummyCards = [MockBuilder.buildCard(), MockBuilder.buildCard()]

    let cardAdminViewModel = CardsAdminViewModel(cards: nil, extraOptionTitle: nil, confirmPromptText: nil)

    func testHasCards() {
        XCTAssertFalse(cardAdminViewModel.hasCards())

        cardAdminViewModel.cards = dummyCard
        XCTAssert(cardAdminViewModel.hasCards())

        cardAdminViewModel.cards = dummyCards
        XCTAssert(cardAdminViewModel.hasCards())
    }

    func testExtraOption() {
        XCTAssertFalse(cardAdminViewModel.hasExtraOption())

        cardAdminViewModel.extraOptionTitle = ""
        XCTAssertFalse(cardAdminViewModel.hasExtraOption())

        cardAdminViewModel.extraOptionTitle = "title"
        XCTAssert(cardAdminViewModel.hasExtraOption())
    }

    func testConfirmPrompt() {
        XCTAssertFalse(cardAdminViewModel.hasConfirmPromptText())

        cardAdminViewModel.confirmPromptText = ""
        XCTAssertFalse(cardAdminViewModel.hasConfirmPromptText())

        cardAdminViewModel.confirmPromptText = "title"
        XCTAssert(cardAdminViewModel.hasConfirmPromptText())
    }

    func testSetTitle() {
        cardAdminViewModel.setScreenTitle(title: "title")
        XCTAssertEqual(cardAdminViewModel.titleScreen, "title")
    }
    func testGetTitle() {
        XCTAssertEqual(cardAdminViewModel.getScreenTitle(), "¿Con qué tarjeta?".localized)
        cardAdminViewModel.titleScreen = "title"
        XCTAssertEqual(cardAdminViewModel.getScreenTitle(), "title")
    }

    func testNumberOfOptions() {
        // Sin Tarjetas ni Opcion Extra
        XCTAssertEqual(cardAdminViewModel.numberOfOptions(), 0)

        // Sin Tarjetas con opcion Extra
        cardAdminViewModel.extraOptionTitle = "title"
        XCTAssertEqual(cardAdminViewModel.numberOfOptions(), 1)

        // Con una tarjeta sin opcion extra 
        cardAdminViewModel.cards = dummyCard
        cardAdminViewModel.extraOptionTitle = ""
        XCTAssertEqual(cardAdminViewModel.numberOfOptions(), 1)

        // Con una tarjeta y opcion extra
        cardAdminViewModel.cards = dummyCard
        cardAdminViewModel.extraOptionTitle = "title"
        XCTAssertEqual(cardAdminViewModel.numberOfOptions(), 2)

        // Con dos tarjeta sin opcion extra
        cardAdminViewModel.cards = dummyCards
        cardAdminViewModel.extraOptionTitle = ""
        XCTAssertEqual(cardAdminViewModel.numberOfOptions(), 2)

        // Con dos tarjeta y opcion extra
        cardAdminViewModel.cards = dummyCards
        cardAdminViewModel.extraOptionTitle = "title"
        XCTAssertEqual(cardAdminViewModel.numberOfOptions(), 3)

    }

    func testGetAlertCardTitle() {
        XCTAssertEqual(cardAdminViewModel.getAlertCardTitle(card: dummyCard[0]), dummyCard[0].getTitle())
        dummyCard[0].paymentMethod?.name = nil
        XCTAssertEqual(cardAdminViewModel.getAlertCardTitle(card: dummyCard[0]), dummyCard[0].getTitle())
        dummyCard[0].paymentMethod?.name = "visa"
        XCTAssertEqual(cardAdminViewModel.getAlertCardTitle(card: dummyCard[0]), "visa " + dummyCard[0].getTitle())
    }

    func testNumberOfSections() {
        XCTAssertEqual(cardAdminViewModel.numberOfSections(), 2)
    }

    func testIsHeaderSectionAndHeight() {
        XCTAssert(cardAdminViewModel.isHeaderSection(section: HEADER_SECTION_NUMBER))
        XCTAssertFalse(cardAdminViewModel.isHeaderSection(section: 1))

        XCTAssertEqual(cardAdminViewModel.sizeForItemAt(indexPath: IndexPath(row: 0, section: HEADER_SECTION_NUMBER)), CGSize(width : cardAdminViewModel.screenWidth, height : cardAdminViewModel.titleCellHeight))

    }

    func testIsCardSection() {
        XCTAssertFalse(cardAdminViewModel.isCardsSection(section: 0))
        XCTAssert(cardAdminViewModel.isCardsSection(section: CARDS_SECTION_NUMBER))
    }

    func testNumberOfItemsInSection() {
        XCTAssertEqual(cardAdminViewModel.numberOfItemsInSection(section: HEADER_SECTION_NUMBER), 1)

        XCTAssertEqual(cardAdminViewModel.numberOfItemsInSection(section: CARDS_SECTION_NUMBER), 0)
        cardAdminViewModel.cards = dummyCard
        XCTAssertEqual(cardAdminViewModel.numberOfItemsInSection(section: CARDS_SECTION_NUMBER), 1)
        cardAdminViewModel.extraOptionTitle = "title"
        XCTAssertEqual(cardAdminViewModel.numberOfItemsInSection(section: CARDS_SECTION_NUMBER), 2)
        cardAdminViewModel.cards = nil
        XCTAssertEqual(cardAdminViewModel.numberOfItemsInSection(section: CARDS_SECTION_NUMBER), 1)
    }

    func testIsCardItemAndHeight() {
        let firstNode = IndexPath(row: 0, section: CARDS_SECTION_NUMBER)
        let secondNode = IndexPath(row: 1, section: CARDS_SECTION_NUMBER)
        let thirdNode = IndexPath(row: 2, section: CARDS_SECTION_NUMBER)

        // No Cards
        XCTAssertFalse(cardAdminViewModel.isCardItemFor(indexPath: IndexPath(row: 0, section: HEADER_SECTION_NUMBER)))
        XCTAssertFalse(cardAdminViewModel.isCardItemFor(indexPath: IndexPath(row: 1, section: HEADER_SECTION_NUMBER)))

        XCTAssertFalse(cardAdminViewModel.isCardItemFor(indexPath: firstNode))
        XCTAssertFalse(cardAdminViewModel.isCardItemFor(indexPath: secondNode))
        XCTAssertEqual(cardAdminViewModel.sizeForItemAt(indexPath: firstNode), CGSize.zero)
        XCTAssertEqual(cardAdminViewModel.sizeForItemAt(indexPath: secondNode), CGSize.zero)
        XCTAssertEqual(cardAdminViewModel.heightOfItem(indexItem: firstNode.row), 0)
        XCTAssertEqual(cardAdminViewModel.heightOfItem(indexItem: secondNode.row), 0)

        // One Card
        cardAdminViewModel.cards = dummyCard
        XCTAssertFalse(cardAdminViewModel.isCardItemFor(indexPath: IndexPath(row: 0, section: HEADER_SECTION_NUMBER)))
        XCTAssertFalse(cardAdminViewModel.isCardItemFor(indexPath: IndexPath(row: 1, section: HEADER_SECTION_NUMBER)))

        XCTAssert(cardAdminViewModel.isCardItemFor(indexPath: firstNode))
        XCTAssertFalse(cardAdminViewModel.isCardItemFor(indexPath: secondNode))
        XCTAssertEqual(cardAdminViewModel.sizeForItemAt(indexPath: firstNode), CGSize(width: cardAdminViewModel.widthPerItem, height: cardAdminViewModel.calculateHeight(indexPath: firstNode)))
        XCTAssertEqual(cardAdminViewModel.sizeForItemAt(indexPath: secondNode), CGSize.zero)

        // Two Cards
        cardAdminViewModel.cards = dummyCards
        XCTAssertFalse(cardAdminViewModel.isCardItemFor(indexPath: IndexPath(row: 0, section: HEADER_SECTION_NUMBER)))
        XCTAssertFalse(cardAdminViewModel.isCardItemFor(indexPath: IndexPath(row: 1, section: HEADER_SECTION_NUMBER)))

        XCTAssert(cardAdminViewModel.isCardItemFor(indexPath: firstNode))
        XCTAssert(cardAdminViewModel.isCardItemFor(indexPath: secondNode))
        XCTAssertFalse(cardAdminViewModel.isCardItemFor(indexPath: thirdNode))

        XCTAssertEqual(cardAdminViewModel.sizeForItemAt(indexPath: firstNode), CGSize(width: cardAdminViewModel.widthPerItem, height: cardAdminViewModel.calculateHeight(indexPath: firstNode)))
        XCTAssertEqual(cardAdminViewModel.sizeForItemAt(indexPath: secondNode), CGSize(width: cardAdminViewModel.widthPerItem, height: cardAdminViewModel.calculateHeight(indexPath: secondNode)))
        XCTAssertEqual(cardAdminViewModel.sizeForItemAt(indexPath: thirdNode), CGSize.zero)
    }

    func testIsExtraItem() {
        let firstNode = IndexPath(row: 0, section: CARDS_SECTION_NUMBER)
        let secondNode = IndexPath(row: 1, section: CARDS_SECTION_NUMBER)
        let thirdNode = IndexPath(row: 2, section: CARDS_SECTION_NUMBER)
        let forthNode = IndexPath(row: 3, section: CARDS_SECTION_NUMBER)

        // No Cards
        cardAdminViewModel.extraOptionTitle = "Extra"
        XCTAssertFalse(cardAdminViewModel.isExtraOptionItemFor(indexPath: IndexPath(row: 0, section: HEADER_SECTION_NUMBER)))
        XCTAssertFalse(cardAdminViewModel.isExtraOptionItemFor(indexPath: IndexPath(row: 1, section: HEADER_SECTION_NUMBER)))

        XCTAssert(cardAdminViewModel.isExtraOptionItemFor(indexPath: firstNode))
        XCTAssertFalse(cardAdminViewModel.isExtraOptionItemFor(indexPath: secondNode))
        XCTAssertEqual(cardAdminViewModel.sizeForItemAt(indexPath: firstNode), CGSize(width: cardAdminViewModel.widthPerItem, height: cardAdminViewModel.calculateHeight(indexPath: firstNode)))
        XCTAssertEqual(cardAdminViewModel.sizeForItemAt(indexPath: secondNode), CGSize.zero)

        // One Card
        cardAdminViewModel.cards = dummyCard
        XCTAssertFalse(cardAdminViewModel.isExtraOptionItemFor(indexPath: IndexPath(row: 0, section: HEADER_SECTION_NUMBER)))
        XCTAssertFalse(cardAdminViewModel.isExtraOptionItemFor(indexPath: IndexPath(row: 1, section: HEADER_SECTION_NUMBER)))

        XCTAssertFalse(cardAdminViewModel.isExtraOptionItemFor(indexPath: firstNode))
        XCTAssert(cardAdminViewModel.isExtraOptionItemFor(indexPath: secondNode))
        XCTAssertFalse(cardAdminViewModel.isExtraOptionItemFor(indexPath: thirdNode))

        XCTAssertNotEqual(cardAdminViewModel.sizeForItemAt(indexPath: firstNode), CGSize.zero)
        XCTAssertEqual(cardAdminViewModel.sizeForItemAt(indexPath: secondNode), CGSize(width: cardAdminViewModel.widthPerItem, height: cardAdminViewModel.calculateHeight(indexPath: secondNode)))
        XCTAssertEqual(cardAdminViewModel.sizeForItemAt(indexPath: thirdNode), CGSize.zero)

        // Two Cards
        cardAdminViewModel.cards = dummyCards
        XCTAssertFalse(cardAdminViewModel.isExtraOptionItemFor(indexPath: IndexPath(row: 0, section: HEADER_SECTION_NUMBER)))
        XCTAssertFalse(cardAdminViewModel.isExtraOptionItemFor(indexPath: IndexPath(row: 1, section: HEADER_SECTION_NUMBER)))

        XCTAssertFalse(cardAdminViewModel.isExtraOptionItemFor(indexPath: firstNode))
        XCTAssertFalse(cardAdminViewModel.isExtraOptionItemFor(indexPath: secondNode))
        XCTAssert(cardAdminViewModel.isExtraOptionItemFor(indexPath: thirdNode))
        XCTAssertFalse(cardAdminViewModel.isExtraOptionItemFor(indexPath: forthNode))

        XCTAssertNotEqual(cardAdminViewModel.sizeForItemAt(indexPath: firstNode), CGSize.zero)
        XCTAssertNotEqual(cardAdminViewModel.sizeForItemAt(indexPath: secondNode), CGSize.zero)
        XCTAssertEqual(cardAdminViewModel.sizeForItemAt(indexPath: thirdNode), CGSize(width: cardAdminViewModel.widthPerItem, height: cardAdminViewModel.calculateHeight(indexPath: thirdNode)))
        XCTAssertEqual(cardAdminViewModel.sizeForItemAt(indexPath: forthNode), CGSize.zero)
    }

    func testIndexOfFirsCardInSection() {
        XCTAssertEqual(cardAdminViewModel.indexOfFirsCardInSection(row: 0), 0)
        XCTAssertEqual(cardAdminViewModel.indexOfFirsCardInSection(row: 1), 0)
        XCTAssertEqual(cardAdminViewModel.indexOfFirsCardInSection(row: 2), 2)
        XCTAssertEqual(cardAdminViewModel.indexOfFirsCardInSection(row: 3), 2)
    }

    func testCalculateHeight() {
        let firstNode = IndexPath(row: 0, section: CARDS_SECTION_NUMBER)
        let secondNode = IndexPath(row: 1, section: CARDS_SECTION_NUMBER)
        let thirdNode = IndexPath(row: 2, section: CARDS_SECTION_NUMBER)
        let forthNode = IndexPath(row: 3, section: CARDS_SECTION_NUMBER)
        XCTAssertEqual(cardAdminViewModel.calculateHeight(indexPath: firstNode), 0)

        cardAdminViewModel.cards = dummyCard
        cardAdminViewModel.extraOptionTitle = "title"
        XCTAssertEqual(cardAdminViewModel.calculateHeight(indexPath: firstNode), cardAdminViewModel.calculateHeight(indexPath: secondNode))
        XCTAssertEqual(cardAdminViewModel.calculateHeight(indexPath: thirdNode), cardAdminViewModel.calculateHeight(indexPath: forthNode))

        // Make second card larger
        dummyCards[1].lastFourDigits = "112321 421412421 41242412 4124214 124124241 42141241"
        cardAdminViewModel.cards = dummyCards
        XCTAssertEqual(cardAdminViewModel.calculateHeight(indexPath: firstNode), cardAdminViewModel.heightOfItem(indexItem: secondNode.row))
    }
}
