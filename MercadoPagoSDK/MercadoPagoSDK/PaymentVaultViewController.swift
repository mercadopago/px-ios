 //
//  PaymentVaultViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 15/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class PaymentVaultViewController: MercadoPagoUIScrollViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var collectionSearch: UICollectionView!

    static public var cantCC = 3
    
    static let VIEW_CONTROLLER_NIB_NAME : String = "PaymentVaultViewController"
    
    var merchantBaseUrl : String!
    var merchantAccessToken : String!
    var publicKey : String!
    var currency : Currency!
    
    
    var defaultInstallments : Int?
    var installments : Int?
    var viewModel : PaymentVaultViewModel!
    
    var bundle = MercadoPago.getBundle()
    
    var titleSectionReference : PaymentVaultTitleCollectionViewCell!
    
    fileprivate var tintColor = true
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    public init(amount : Double, paymentPreference : PaymentPreference?, callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token?, _ issuer: Issuer?, _ payerCost: PayerCost?) -> Void, callbackCancel : ((Void) -> Void)? = nil) {
        super.init(nibName: PaymentVaultViewController.VIEW_CONTROLLER_NIB_NAME, bundle: bundle)
        self.initCommon()
        self.initViewModel(amount, paymentPreference : paymentPreference, callback: callback)
        
        self.callbackCancel = callbackCancel
        
    }
    
    public init(amount : Double, paymentPreference : PaymentPreference? = nil, paymentMethodSearch : PaymentMethodSearch, tintColor : Bool = false,
                callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token?, _ issuer: Issuer?, _ payerCost: PayerCost?) -> Void,
                callbackCancel : ((Void) -> Void)? = nil) {
        super.init(nibName: PaymentVaultViewController.VIEW_CONTROLLER_NIB_NAME, bundle: bundle)
        self.initCommon()
        self.initViewModel(amount, paymentPreference: paymentPreference, customerPaymentMethods: paymentMethodSearch.customerPaymentMethods, paymentMethodSearchItem : paymentMethodSearch.groups, paymentMethods: paymentMethodSearch.paymentMethods, callback: callback)
        
        self.callbackCancel = callbackCancel
        
    }
    
    internal init(amount: Double, paymentPreference : PaymentPreference?, paymentMethodSearchItem : [PaymentMethodSearchItem]? = nil, paymentMethods: [PaymentMethod], title: String? = "", tintColor : Bool = false, callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token?, _ issuer: Issuer?, _ payerCost: PayerCost?) -> Void, callbackCancel : ((Void) -> Void)? = nil) {
        
        super.init(nibName: PaymentVaultViewController.VIEW_CONTROLLER_NIB_NAME, bundle: bundle)
        
        self.initCommon()
        self.initViewModel(amount, paymentPreference: paymentPreference, paymentMethodSearchItem: paymentMethodSearchItem, paymentMethods: paymentMethods, callback : callback)
        
        self.title = title
        self.tintColor = tintColor
        
        self.callbackCancel = callbackCancel
        
        
    }
    
    fileprivate func initCommon(){
        
        self.merchantBaseUrl = MercadoPagoContext.baseURL()
        self.merchantAccessToken = MercadoPagoContext.merchantAccessToken()
        self.publicKey = MercadoPagoContext.publicKey()
        self.currency = MercadoPagoContext.getCurrency()
    }
    
    var loadingGroups = true
    
    fileprivate func initViewModel(_ amount : Double, paymentPreference : PaymentPreference?, customerPaymentMethods: [CardInformation]? = nil, paymentMethodSearchItem : [PaymentMethodSearchItem]? = nil, paymentMethods: [PaymentMethod]? = nil, callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token?, _ issuer: Issuer?, _ payerCost: PayerCost?) -> Void){
        self.viewModel = PaymentVaultViewModel(amount: amount, paymentPrefence: paymentPreference)
        
        self.viewModel.setPaymentMethodSearch(paymentMethods: paymentMethods, paymentMethodSearchItems: paymentMethodSearchItem, customerPaymentMethods : customerPaymentMethods)
        self.viewModel.callback = callback
    }
    
    
    required  public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        var upperFrame = self.collectionSearch.bounds
        upperFrame.origin.y = -upperFrame.size.height + 10;
        upperFrame.size.width = UIScreen.main.bounds.width
        let upperView = UIView(frame: upperFrame)
        upperView.backgroundColor = MercadoPagoContext.getPrimaryColor()
        collectionSearch.addSubview(upperView)
        
        if self.title == nil || self.title!.isEmpty {
            self.title = "¿Cómo quiéres pagar?".localized
        }
        
        self.registerAllCells()
        
        if callbackCancel == nil {
            self.callbackCancel = {(Void) -> Void in
                if self.navigationController?.viewControllers[0] == self {
                    self.dismiss(animated: true, completion: {
                        
                    })
                } else {
                    self.navigationController!.popViewController(animated: true)
                }
            }
        } else {
            self.callbackCancel = callbackCancel
        }

       self.collectionSearch.backgroundColor = UIColor.white()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hideNavBar()
        
        self.navigationItem.leftBarButtonItem!.action = #selector(invokeCallbackCancel)
        self.navigationController!.navigationBar.shadowImage = nil
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getCustomerCards()
        self.hideNavBarCallback = self.hideNavBarCallbackDisplayTitle()
    }



    fileprivate func cardFormCallbackCancel() -> ((Void) -> (Void)) {
        return { Void -> (Void) in
            if self.viewModel.getDisplayedPaymentMethodsCount() > 1 {
                self.navigationController!.popToViewController(self, animated: true)
            } else {
                self.navigationController!.popToViewController(self, animated: true)
                self.callbackCancel!()
            }
        }
    }
    
    fileprivate func getCustomerCards(){
       
        if self.viewModel!.shouldGetCustomerCardsInfo() {
            MerchantServer.getCustomer({ (customer: Customer) -> Void in
                self.hideLoading()
                self.viewModel.customerCards = customer.cards
                self.loadPaymentMethodSearch()
                
            }, failure: { (error: NSError?) -> Void in
                self.hideLoading()
            })
        } else {
            self.loadPaymentMethodSearch()
        }
    }
    
    fileprivate func hideNavBarCallbackDisplayTitle() -> ((Void) -> (Void)) {
        return { Void -> (Void) in
            if self.titleSectionReference != nil {
                self.titleSectionReference.fillCell()
            }
        }
    }

    
    fileprivate func loadPaymentMethodSearch(){
        
        if self.viewModel.currentPaymentMethodSearch == nil {
            MPServicesBuilder.searchPaymentMethods(self.viewModel.amount, excludedPaymentTypeIds: viewModel.getExcludedPaymentTypeIds(), excludedPaymentMethodIds: viewModel.getExcludedPaymentMethodIds(), success: { (paymentMethodSearchResponse: PaymentMethodSearch) -> Void in
                
                self.viewModel.setPaymentMethodSearchResponse(paymentMethodSearchResponse)
                self.hideLoading()
                self.loadPaymentMethodSearch()
                
            }, failure: { (error) -> Void in
                self.hideLoading()
                self.requestFailure(error, callback: {
                    self.navigationController!.dismiss(animated: true, completion: {})
                }, callbackCancel: {
                    self.invokeCallbackCancel()
                })
            })
            
        } else {
            
            if self.viewModel.currentPaymentMethodSearch.count == 1 && self.viewModel.currentPaymentMethodSearch[0].children.count > 0 {
                self.viewModel.currentPaymentMethodSearch = self.viewModel.currentPaymentMethodSearch[0].children
            }
            
            if  self.viewModel.currentPaymentMethodSearch.count == 1 && self.viewModel.getCustomerPaymentMethodsToDisplayCount() == 0{
                self.viewModel.optionSelected(self.viewModel.currentPaymentMethodSearch[0],navigationController: self.navigationController!, cancelPaymentCallback: self.cardFormCallbackCancel(), animated: false)
            } else {
                self.collectionSearch.delegate = self
                self.collectionSearch.dataSource = self
                self.loadingGroups = false
                self.collectionSearch.reloadData()
            }
        }
    }
    


    fileprivate func registerAllCells(){
   
        let collectionSearchCell = UINib(nibName: "PaymentSearchCollectionViewCell", bundle: self.bundle)
        self.collectionSearch.register(collectionSearchCell, forCellWithReuseIdentifier: "searchCollectionCell")
        
        let paymentVaultTitleCollectionViewCell = UINib(nibName: "PaymentVaultTitleCollectionViewCell", bundle: self.bundle)
        self.collectionSearch.register(paymentVaultTitleCollectionViewCell, forCellWithReuseIdentifier: "paymentVaultTitleCollectionViewCell")
        
    }
    
    override func getNavigationBarTitle() -> String {
        if self.titleSectionReference != nil {
            self.titleSectionReference.title.text = ""
        }
        return "¿Cómo quiéres pagar?".localized
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        //En caso de que el vc no sea root
        if (navigationController != nil && navigationController!.viewControllers.count > 1 && navigationController!.viewControllers[0] != self) || (navigationController != nil && navigationController!.viewControllers.count == 1) {
            if self.viewModel!.isRoot {
                self.callbackCancel!()
            }
            return true
        }
        return false
    }


    func defaultsPaymentMethodsSection() -> Int{
        if (self.viewModel.getCustomerPaymentMethodsToDisplayCount() > 0){
            return 2
        } else{
            return 1
        }
        
    }
    
   

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if (self.viewModel.getCustomerPaymentMethodsToDisplayCount() > 0){
            return 3
        }else{
            return 2
        }

    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch (indexPath as NSIndexPath).section {
        
        case defaultsPaymentMethodsSection():
            let paymentSearchItemSelected = self.viewModel.currentPaymentMethodSearch[(indexPath as NSIndexPath).row]
            collectionView.deselectItem(at: indexPath, animated: true)
            if (paymentSearchItemSelected.children.count > 0) {
                let paymentVault = PaymentVaultViewController(amount: self.viewModel.amount, paymentPreference: self.viewModel.paymentPreference, paymentMethodSearchItem: paymentSearchItemSelected.children, paymentMethods : self.viewModel.paymentMethods, title:paymentSearchItemSelected.childrenHeader, callback: { (paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost: PayerCost?) -> Void in
                    self.viewModel.callback!(paymentMethod, token, issuer, payerCost)
                })
                paymentVault.viewModel!.isRoot = false
                self.navigationController!.pushViewController(paymentVault, animated: true)
            } else {
                self.showLoading()
                self.viewModel.optionSelected(paymentSearchItemSelected, navigationController: self.navigationController!, cancelPaymentCallback: cardFormCallbackCancel())
            }
        default:
            if self.viewModel!.getCustomerPaymentMethodsToDisplayCount() > 0 {
                let customerCardSelected = self.viewModel.customerCards![(indexPath as NSIndexPath).row] as CardInformation

                let paymentMethodSelected = Utils.findPaymentMethod(self.viewModel.paymentMethods, paymentMethodId: customerCardSelected.getPaymentMethodId())
                if paymentMethodSelected.isAccountMoney() {
                    self.viewModel.callback!(paymentMethodSelected, nil, nil, nil)
                } else {
                    customerCardSelected.setupPaymentMethod(paymentMethodSelected)
                    customerCardSelected.setupPaymentMethodSettings(paymentMethodSelected.settings)
                    let cardFlow = MPFlowBuilder.startCardFlow(amount: self.viewModel.amount, cardInformation : customerCardSelected, callback: { (paymentMethod,   token, issuer, payerCost) in
                        self.viewModel!.callback!(paymentMethod, token, issuer, payerCost)
                        }, callbackCancel: {
                            self.navigationController!.popToViewController(self, animated: true)
                    })
                    self.navigationController?.pushViewController(cardFlow.viewControllers[0], animated: true)
                }
            }
        }
    }
    

    public func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        
        if (self.loadingGroups){
            return 0
        }
        switch section {
        case 0 :
            return 1
        case defaultsPaymentMethodsSection():
            if let pms = self.viewModel.currentPaymentMethodSearch{
              return pms.count
            }else{
               return 0
            }
            
        default:
            return self.viewModel.getCustomerPaymentMethodsToDisplayCount()
        }
    }
    

    public func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCollectionCell",
                 
                                                      for: indexPath) as! PaymentSearchCollectionViewCell

        switch indexPath.section {
        case 0 :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "paymentVaultTitleCollectionViewCell",
                                                          
                                                          for: indexPath) as! PaymentVaultTitleCollectionViewCell
            self.titleSectionReference = cell
            titleCell = cell
            return cell
        case defaultsPaymentMethodsSection():
            let currentPaymentMethod = self.viewModel.currentPaymentMethodSearch[indexPath.row]
            cell.fillCell(searchItem: currentPaymentMethod)
        default:
            let currentCustomPaymentMethod = self.viewModel.customerCards?[indexPath.row]
            cell.fillCell(cardInformation: currentCustomPaymentMethod!)
        }
        
        

        return cell
    }
    fileprivate let itemsPerRow: CGFloat = 2
    
    var sectionHeight : CGSize?
    
    override func scrollPositionToShowNavBar () -> CGFloat {
        return titleCellHeight - navBarHeigth - statusBarHeigth
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let paddingSpace = CGFloat(32.0)
        let availableWidth = view.frame.width - paddingSpace
        
        titleCellHeight = 82
        if indexPath.section == 0 {
            return CGSize(width : view.frame.width, height : titleCellHeight)
        }
        
       
        
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: maxHegithRow(indexPath:indexPath)  )
    }
    
    private func maxHegithRow(indexPath: IndexPath) -> CGFloat{
        
        if indexPath.section == self.defaultsPaymentMethodsSection() {
            return self.calculateHeight(indexPath: indexPath, numberOfCells: self.viewModel.currentPaymentMethodSearch.count)
        } else {
            return self.calculateHeight(indexPath: indexPath, numberOfCells: self.viewModel.getCustomerPaymentMethodsToDisplayCount(), customerPaymentMethods: true)
        }
        
    }
    
    private func calculateHeight(indexPath : IndexPath, numberOfCells : Int, customerPaymentMethods : Bool = false) -> CGFloat {
        if numberOfCells == 0 {
            return 0
        }
        
        let section : Int
        let row = indexPath.row
        if row % 2 == 1{
            section = (row - 1) / 2
        }else{
            section = row / 2
        }
        let index1 = (section  * 2)
        let index2 = (section  * 2) + 1
        
        if index1 + 1 > numberOfCells {
            return 0
        }
        
        let height1 = heightOfItem(indexItem: index1, customerPaymentMethods: customerPaymentMethods)
        
        if index2 + 1 > numberOfCells {
            return height1
        }
        
        let height2 = heightOfItem(indexItem: index2, customerPaymentMethods: customerPaymentMethods)
        
        
        return height1 > height2 ? height1 : height2

    }
    
    func heightOfItem(indexItem : Int, customerPaymentMethods : Bool) -> CGFloat {
        
        if customerPaymentMethods {
            let currentPaymentMethod = self.viewModel.customerCards![indexItem]
            return PaymentSearchCollectionViewCell.totalHeight(searchItem: currentPaymentMethod)
        }
        
        let currentPaymentMethod = self.viewModel.currentPaymentMethodSearch![indexItem]
        return PaymentSearchCollectionViewCell.totalHeight(searchItem: currentPaymentMethod)

    }
    

    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 8, 8, 8)
    }

    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView){
        self.didScrollInTable(scrollView)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.hideLoading()
    }
    
 }



class PaymentVaultViewModel : NSObject {

    var amount : Double
    var paymentPreference : PaymentPreference?
    
    var customerCards : [CardInformation]?
    var paymentMethods : [PaymentMethod]!
    var currentPaymentMethodSearch : [PaymentMethodSearchItem]!
    var cards : [Card]?
    
    var callback : ((_ paymentMethod: PaymentMethod, _ token:Token?, _ issuer: Issuer?, _ payerCost: PayerCost?) -> Void)!
    
    internal var isRoot = true
    
    init(amount : Double, paymentPrefence : PaymentPreference?){
        self.amount = amount
        self.paymentPreference = paymentPrefence
    }
    
    func shouldGetCustomerCardsInfo() -> Bool {
        return MercadoPagoContext.isCustomerInfoAvailable() && self.isRoot && (self.customerCards == nil || self.customerCards?.count == 0)
    }
    
    func getCustomerPaymentMethodsToDisplayCount() -> Int {
        if (self.customerCards != nil && self.customerCards?.count > 0) {
            return (self.customerCards!.count <= PaymentVaultViewController.cantCC ? self.customerCards!.count : PaymentVaultViewController.cantCC)
        }
        return 0
        
    }
    
    func getDisplayedPaymentMethodsCount() -> Int {
        return self.getCustomerPaymentMethodsToDisplayCount() + self.currentPaymentMethodSearch.count
    }
    
    func getCustomerCardRowHeight() -> CGFloat {
        return self.getCustomerPaymentMethodsToDisplayCount() > 0 ? CustomerPaymentMethodCell.ROW_HEIGHT : 0
    }
    
    func getPaymentMethodRowHeight(_ rowIndex : Int) -> CGFloat {
        
        let currentPaymentMethodSearchItem = self.currentPaymentMethodSearch[rowIndex]
        if currentPaymentMethodSearchItem.showIcon {
            if currentPaymentMethodSearchItem.isPaymentMethod() && !currentPaymentMethodSearchItem.isBitcoin() {
                if currentPaymentMethodSearchItem.comment != nil && currentPaymentMethodSearchItem.comment!.characters.count > 0 {
                    return OfflinePaymentMethodCell.ROW_HEIGHT
                } else {
                    return OfflinePaymentMethodWithDescriptionCell.ROW_HEIGHT
                }
            }
            return PaymentSearchCell.ROW_HEIGHT
        }
        return PaymentTitleViewCell.ROW_HEIGHT
    }
    
    func getExcludedPaymentTypeIds() -> Set<String>? {
        return (self.paymentPreference != nil) ? self.paymentPreference!.excludedPaymentTypeIds : nil
    }
    
    func getExcludedPaymentMethodIds() -> Set<String>? {
        return (self.paymentPreference != nil) ? self.paymentPreference!.excludedPaymentMethodIds : nil
    }
    
    func setPaymentMethodSearchResponse(_ paymentMethodSearchResponse : PaymentMethodSearch){
        self.setPaymentMethodSearch(paymentMethods: paymentMethodSearchResponse.paymentMethods, paymentMethodSearchItems: paymentMethodSearchResponse.groups, customerPaymentMethods : paymentMethodSearchResponse.customerPaymentMethods)
    }
    
    func setPaymentMethodSearch(paymentMethods : [PaymentMethod]? = nil, paymentMethodSearchItems : [PaymentMethodSearchItem]? = nil, customerPaymentMethods : [CardInformation]? = nil) {
        self.paymentMethods = paymentMethods
        self.currentPaymentMethodSearch = paymentMethodSearchItems
        
        var currentCustomerCards = customerPaymentMethods
        if customerPaymentMethods != nil && customerPaymentMethods!.count > 0 {
            let accountMoneyAvailable = MercadoPagoContext.accountMoneyAvailable()
            if !accountMoneyAvailable {
                currentCustomerCards = customerPaymentMethods!.filter({ (element : CardInformation) -> Bool in
                    return element.getPaymentMethodId() != PaymentTypeId.ACCOUNT_MONEY.rawValue
                })
            }
            self.customerCards = currentCustomerCards
        }
        
        
    }
    
    
    internal func optionSelected(_ paymentSearchItemSelected : PaymentMethodSearchItem, navigationController : UINavigationController, cancelPaymentCallback : @escaping ((Void) -> (Void)),animated: Bool = true) {
        
        switch paymentSearchItemSelected.type.rawValue {
        case PaymentMethodSearchItemType.PAYMENT_TYPE.rawValue:
            let paymentTypeId = PaymentTypeId(rawValue: paymentSearchItemSelected.idPaymentMethodSearchItem)
            
            if paymentTypeId!.isCard() {
                let cardFlow = MPFlowBuilder.startCardFlow(self.paymentPreference, amount: self.amount, paymentMethods : self.paymentMethods, callback: { (paymentMethod, token, issuer, payerCost) in
                    self.callback!(paymentMethod, token, issuer, payerCost)
                }, callbackCancel: {
                    cancelPaymentCallback()
                })
                
                navigationController.pushViewController(cardFlow.viewControllers[0], animated: animated)
            } else {
                navigationController.pushViewController(MPStepBuilder.startPaymentMethodsStep(callback: {    (paymentMethod : PaymentMethod) -> Void in
                    self.callback!(paymentMethod, nil, nil, nil)
                }), animated: true)
            }
            break
        case PaymentMethodSearchItemType.PAYMENT_METHOD.rawValue:
            if paymentSearchItemSelected.idPaymentMethodSearchItem == PaymentTypeId.ACCOUNT_MONEY.rawValue {
                //MP wallet
            } else if paymentSearchItemSelected.idPaymentMethodSearchItem == PaymentTypeId.BITCOIN.rawValue {
                
            } else {
                // Offline Payment Method
                let offlinePaymentMethodSelected = Utils.findPaymentMethod(self.paymentMethods, paymentMethodId: paymentSearchItemSelected.idPaymentMethodSearchItem)
                self.callback!(offlinePaymentMethodSelected, nil, nil, nil)
            }
            break
        default:
            //TODO : HANDLE ERROR
            break
        }
    }
    
}

