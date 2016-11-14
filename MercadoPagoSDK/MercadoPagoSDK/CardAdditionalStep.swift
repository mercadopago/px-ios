//
//  CardAdditionalStep.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/13/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class CardAdditionalStep: MercadoPagoUIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var bundle : Bundle? = MercadoPago.getBundle()
    let viewModel : CardAdditionalStepViewModel!
    var navBarHeight: CGFloat = 0
    var startScrollPosition: CGFloat = 0
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        loadMPStyles()
       
        var upperFrame = self.tableView.bounds
        upperFrame.origin.y = -upperFrame.size.height;
        let upperView = UIView(frame: upperFrame)
        upperView.backgroundColor = MercadoPagoContext.getPrimaryColor()
        tableView.addSubview(upperView)
        
        self.showNavBar()
        
        let titleNib = UINib(nibName: "PayerCostTitleTableViewCell", bundle: self.bundle)
        self.tableView.register(titleNib, forCellReuseIdentifier: "titleNib")
        let cardNib = UINib(nibName: "PayerCostCardTableViewCell", bundle: self.bundle)
        self.tableView.register(cardNib, forCellReuseIdentifier: "cardNib")
        let rowInstallmentNib = UINib(nibName: "PayerCostRowTableViewCell", bundle: self.bundle)
        self.tableView.register(rowInstallmentNib, forCellReuseIdentifier: "rowInstallmentNib")
        let rowIssuerNib = UINib(nibName: "IssuerRowTableViewCell", bundle: self.bundle)
        self.tableView.register(rowIssuerNib, forCellReuseIdentifier: "rowIssuerNib")
        let cardTypeNib = UINib(nibName: "CardTypeTableViewCell", bundle: self.bundle)
        self.tableView.register(cardTypeNib, forCellReuseIdentifier: "cardTypeNib")
        
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let indexPath = IndexPath(row: 0, section: 0)
        //self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        
        self.hideNavBar()
        
        if !self.viewModel.hasIssuer() {
            self.showLoading()
            self.getIssuers()
        } else if self.viewModel.hasPaymentMethod(){
            if self.viewModel.installment == nil {
                self.showLoading()
                self.getInstallments()
            } else {
                self.viewModel.payerCosts = self.viewModel.installment!.payerCosts
            }
        }
        
        DispatchQueue.main.async() {
            
            self.tableView.setContentOffset(CGPoint(x:0, y: -64.0), animated: false)
            
        }
        navBarHeight = (self.navigationController?.navigationBar.frame.height)!
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = ""
        
        startScrollPosition = tableView.contentOffset.y
    }
    
    override func loadMPStyles(){
        if self.navigationController != nil {
            self.navigationController!.interactivePopGestureRecognizer?.delegate = self
            self.navigationController?.navigationBar.tintColor = UIColor(red: 255, green: 255, blue: 255)
            self.navigationController?.navigationBar.barTintColor = MercadoPagoContext.getPrimaryColor()
            self.navigationController?.navigationBar.removeBottomLine()
            self.navigationController?.navigationBar.isTranslucent = false
            
            self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow") //saca linea molesta
            displayBackButton()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(paymentMethod : [PaymentMethod] ,issuer : Issuer?, token : CardInformationForm?, amount: Double?, paymentPreference: PaymentPreference?,installment: Installment?, timer: CountdownTimer?, callback: ((_ payerCost: NSObject?)->Void)? ){
        
        self.viewModel = CardAdditionalStepViewModel(paymentMethod: paymentMethod, issuer: issuer, token: token, amount: amount, paymentPreference: paymentPreference, installment:installment, callback: callback)
        
        super.init(nibName: "CardAdditionalStep", bundle: self.bundle)
        self.timer=timer
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return navBarHeight
        case 1:
            return self.viewModel.getCardCellHeight()
        case 2:
            return self.viewModel.gerRowCellHeight()
        
        default:
            return 60
        }
        
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0 || section == 1){
            return 1
        } else {
            return self.viewModel.numberOfPayerCost()
        }
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0){
            
            let titleCell = tableView.dequeueReusableCell(withIdentifier: "titleNib", for: indexPath as IndexPath) as! PayerCostTitleTableViewCell
            titleCell.selectionStyle = .none
            titleCell.setTitle(string: self.viewModel.getTilte())
            titleCell.backgroundColor = MercadoPagoContext.getPrimaryColor()
            
            return titleCell
            
        } else if (indexPath.section == 1){
            let cardCell = tableView.dequeueReusableCell(withIdentifier: "cardNib", for: indexPath as IndexPath) as! PayerCostCardTableViewCell
            cardCell.selectionStyle = .none
            cardCell.loadCard()
            cardCell.updateCardSkin(token: self.viewModel.token, paymentMethod: self.viewModel.paymentMethod[0])
            cardCell.backgroundColor = MercadoPagoContext.getPrimaryColor()
            
            return cardCell
            
        } else {
            if self.viewModel.hasIssuer(){
                let payerCost : PayerCost = self.viewModel.payerCosts![indexPath.row]
                let installmentCell = tableView.dequeueReusableCell(withIdentifier: "rowInstallmentNib", for: indexPath as IndexPath) as! PayerCostRowTableViewCell
                installmentCell.fillCell(payerCost: payerCost)
                installmentCell.selectionStyle = .none
                installmentCell.addSeparatorLineToTop(width: Double(installmentCell.contentView.frame.width), y:Float(installmentCell.contentView.bounds.maxY))
                
                return installmentCell
            } else  if self.viewModel.hasPaymentMethod(){
                let issuer : Issuer = self.viewModel.issuersList![indexPath.row]
                let issuerCell = tableView.dequeueReusableCell(withIdentifier: "rowIssuerNib", for: indexPath as IndexPath) as! IssuerRowTableViewCell
                issuerCell.fillCell(issuer: issuer, bundle: self.bundle!)
                issuerCell.selectionStyle = .none
                issuerCell.addSeparatorLineToTop(width: Double(issuerCell.contentView.frame.width), y:Float(issuerCell.contentView.bounds.maxY))
                
                return issuerCell
            } else{
                let cardType = tableView.dequeueReusableCell(withIdentifier: "cardTypeNib", for: indexPath as IndexPath) as! CardTypeTableViewCell
                cardType.setPaymentMethod(paymentMethod: self.viewModel.paymentMethod[indexPath.row])
                cardType.addSeparatorLineToTop(width: Double(cardType.contentView.frame.width), y:Float(cardType.contentView.bounds.maxY))
                return cardType
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 2){
            if self.viewModel.hasIssuer(){
                let payerCost : PayerCost = self.viewModel.payerCosts![(indexPath as NSIndexPath).row]
                self.viewModel.callback!(payerCost)
            } else if self.viewModel.hasPaymentMethod(){
                let issuer : Issuer = self.viewModel.issuersList![(indexPath as NSIndexPath).row]
                self.viewModel.callback!(issuer)
            } else {
                let paymentMethod : PaymentMethod = self.viewModel.paymentMethod[(indexPath as NSIndexPath).row]
                self.viewModel.callback!(paymentMethod)
            }
        }
    }
    
    func showNavBar() {
        self.title = self.viewModel.getTilte()
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.tintColor = nil
        self.navigationController?.navigationBar.isTranslucent = false
        let font : UIFont = UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: 22) ?? UIFont.systemFont(ofSize: 22)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.systemFontColor(), NSFontAttributeName: font]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
    }
    func hideNavBar(){
        self.title = ""
        navigationController?.navigationBar.titleTextAttributes = nil
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    var once = false
    var lastContentOffset: CGFloat = 0
    var scrollingDown = false
    
    func wholeTableVisible() -> Bool{
        if tableView.numberOfRows(inSection: 2)>0 {
            let cellRow = tableView.cellForRow(at: IndexPath(row: tableView.numberOfRows(inSection: 2)-1, section: 2))
            
            let cellTitle = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
            if cellRow != nil && cellTitle != nil {
                let overlapRow = (cellRow?.frame)!.intersection(tableView.bounds);
                let overlapTitle = (cellTitle?.frame)!.intersection(tableView.bounds);
                if overlapRow.height == cellRow?.frame.height && overlapTitle.height == cellTitle?.frame.height {
                    return true
                }
            }
        }
        return false
        
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView){
        var titleVisible = false
        var offset = scrollView.contentOffset;
        
        if (scrollView.contentOffset.y >= -30 && wholeTableVisible())
        {
            offset.y = -30;
            scrollView.contentOffset = offset;
            titleVisible = false
            self.title = self.viewModel.getTilte()
        }
        let visibleIndexPaths = self.tableView.indexPathsForVisibleRows!
        for index in visibleIndexPaths {
            if (index.section == 0){
                if !once {
                    hideNavBar()
                    titleVisible = true
                    
                    if (0 < tableView.contentOffset.y + (UIApplication.shared.statusBarFrame.size.height)){
                        
                        titleVisible = false
                        once = true
                        showNavBar()
                    }
                } else {
                    if scrollingDown {
                        once = false
                    }
                }
            } else if index.section == 1  {
                if let card = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? PayerCostCardTableViewCell{
                if tableView.contentOffset.y > 0{
                    if 44/tableView.contentOffset.y < 0.265 && !scrollingDown{
                        card.fadeCard()
                    } else{
                        card.cardView.alpha = 44/tableView.contentOffset.y;
                    }
                }
                }
            }
        }
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            scrollingDown = true
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
            scrollingDown = false
        }
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    fileprivate func getInstallments(){
        let bin = self.viewModel.token?.getCardBin() ?? ""
        MPServicesBuilder.getInstallments(bin, amount: self.viewModel.amount, issuer: self.viewModel.issuer, paymentMethodId: self.viewModel.paymentMethod[0]._id, success: { (installments) -> Void in
            self.viewModel.installment = installments?[0]
            self.viewModel.payerCosts = installments![0].payerCosts
            self.tableView.reloadData()
            self.hideLoading()
        }) { (error) -> Void in
            self.requestFailure(error)
        }
    }
    fileprivate func getIssuers(){
        MPServicesBuilder.getIssuers(self.viewModel.paymentMethod[0], bin: self.viewModel.token?.getCardBin(), success: { (issuers) -> Void in
            self.viewModel.issuersList = issuers
            self.tableView.reloadData()
            self.hideLoading()
        }) { (error) -> Void in
            self.requestFailure(error)
        }
    }
    
}
class CardAdditionalStepViewModel : NSObject {
    
    var payerCosts : [PayerCost]?
    var installment : Installment?
    var paymentMethod : [PaymentMethod]
    var token : CardInformationForm?
    var issuer: Issuer?
    var amount: Double!
    var paymentPreference: PaymentPreference?
    var issuersList:[Issuer]?
    var callback : ((_ payerCost: NSObject?) -> Void)?
    
    init(paymentMethod : [PaymentMethod] ,issuer : Issuer?, token : CardInformationForm?, amount: Double?, paymentPreference: PaymentPreference?,installment: Installment?, callback: ((_ payerCost: NSObject?)->Void)? ){
        self.paymentMethod = paymentMethod
        self.payerCosts = installment?.payerCosts
        self.installment = installment
        self.token = token
        self.amount = amount
        self.issuer = issuer
        self.paymentPreference = paymentPreference
        self.callback = callback
    }
    func numberOfPayerCost() -> Int{
        if hasIssuer(){
            return (self.installment?.numberOfPayerCostToShow(self.paymentPreference?.maxAcceptedInstallments)) ?? 0
        }else if hasPaymentMethod(){
            return (issuersList?.count) ?? 0
        } else {
            return paymentMethod.count 
        }
    }
    func getTilte() -> String{
        if hasIssuer() {
            return "¿En cuántas cuotas?".localized
        } else if hasPaymentMethod(){
            return "¿Quién emitió tu tarjeta?".localized
        } else {
            return "¿Qué tipo de tarjeta es?".localized
        }
    }
    func hasIssuer()-> Bool{
        return issuer != nil
    }
    func hasPaymentMethod()->Bool{
        if (paymentMethod.count)>1{
            return false
        } else {
            return true
        }
    }
    func getCardCellHeight() -> CGFloat {
        return UIScreen.main.bounds.height*0.27
    }
    func gerRowCellHeight() -> CGFloat {
        if hasIssuer() {
            return 60
        } else {
            return 80
        }
    }
}
