//
//  HeaderViewModel.swift
//  MercadoPagoSDKV4
//
//  Created by Vinicius De Andrade Silva on 29/06/21.
//

final class HeaderViewModel {
    // MARK: - Private properties
    private let selectedCard: PXCardSliderViewModel
    private let amountHelper: PXAmountHelper
    private let additionalInfoSummary: PXAdditionalInfoSummary
    private let shouldDisplayChargesHelp: Bool
    private let item: PXItem
    
    // MARK: - Initialization
    init(
        selectedCard: PXCardSliderViewModel,
        amountHelper: PXAmountHelper,
        additionalInfoSummary: PXAdditionalInfoSummary,
        shouldDisplayChargesHelp: Bool,
        item: PXItem
    ) {
        self.selectedCard = selectedCard
        self.amountHelper = amountHelper
        self.additionalInfoSummary = additionalInfoSummary
        self.shouldDisplayChargesHelp = shouldDisplayChargesHelp
        self.item = item
    }
    
    // MARK: - Public methods
    func getHeaderViewModel() -> PXOneTapHeaderViewModel {
        
        let splitConfiguration = selectedCard.getSelectedApplication()?.amountConfiguration?.splitConfiguration
        let composer = PXSummaryComposer(amountHelper: amountHelper,
                                         additionalInfoSummary: additionalInfoSummary,
                                         selectedCard: selectedCard,
                                         shouldDisplayChargesHelp: shouldDisplayChargesHelp)
        updatePaymentData(composer: composer)
        let summaryData = composer.summaryItems
        // Populate header display data. From SP pref AdditionalInfo or instore retrocompatibility.
        let (headerTitle, headerSubtitle, headerImage) = getSummaryHeader(item: item, additionalInfoSummaryData: additionalInfoSummary)
        
        let headerVM = PXOneTapHeaderViewModel(icon: headerImage, title: headerTitle, subTitle: headerSubtitle, data: summaryData, splitConfiguration: splitConfiguration)
        
        return headerVM
    }
    
    // MARK: - Private methods
    private func updatePaymentData(composer: PXSummaryComposer) {
        if let discountData = composer.getDiscountData() {
            let discountConfiguration = discountData.discountConfiguration
            let campaign = discountData.campaign
            let discount = discountConfiguration.getDiscountConfiguration().discount
            let consumedDiscount = !discountConfiguration.getDiscountConfiguration().isAvailable
            amountHelper.getPaymentData().setDiscount(discount, withCampaign: campaign, consumedDiscount: consumedDiscount)
        } else {
            amountHelper.getPaymentData().clearDiscount()
        }
    }
    
    private func getSummaryHeader(item: PXItem?, additionalInfoSummaryData: PXAdditionalInfoSummary?) -> (title: String, subtitle: String?, image: UIImage) {
        var headerImage: UIImage = UIImage()
        var headerTitle: String = ""
        var headerSubtitle: String?
        if let defaultImage = ResourceManager.shared.getImage("MPSDK_review_iconoCarrito_white") {
            headerImage = defaultImage
        }
        
        if let additionalSummaryData = additionalInfoSummaryData, let additionalSummaryTitle = additionalSummaryData.title, !additionalSummaryTitle.isEmpty {
            // SP and new scenario based on Additional Info Summary
            headerTitle = additionalSummaryTitle
            headerSubtitle = additionalSummaryData.subtitle
            if let headerUrl = additionalSummaryData.imageUrl {
                headerImage = PXUIImage(url: headerUrl)
            }
        } else {
            // Instore scenario. Retrocompatibility
            // To deprecate. After instore migrate current preferences.
            
            // Title desc from item
            if let headerTitleStr = item?._description, headerTitleStr.isNotEmpty {
                headerTitle = headerTitleStr
            } else if let headerTitleStr = item?.title, headerTitleStr.isNotEmpty {
                headerTitle = headerTitleStr
            }
            headerSubtitle = nil
            // Image from item
            if let headerUrl = item?.getPictureURL(), headerUrl.isNotEmpty {
                headerImage = PXUIImage(url: headerUrl)
            }
        }
        return (title: headerTitle, subtitle: headerSubtitle, image: headerImage)
    }
    
}
