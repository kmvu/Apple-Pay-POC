//
//  PaymentViewController.swift
//  Apple_pay_POC
//
//  Created by Khang Vu on 7/3/19.
//  Copyright © 2019 Tigerspike. All rights reserved.
//

import UIKit
import PassKit

fileprivate struct ShippingMethod {
    let price: NSDecimalNumber
    let title: String
    let description: String
 
    static let ShippingMethodOptions = [
        ShippingMethod(price: 15.00, title: "First Carrier", description: "You got it today!"),
        ShippingMethod(price: 10.00, title: "Second Carrier", description: "You'll get it tomorrow :\\"),
        ShippingMethod(price: 5.00, title: "Third Carrier", description: "You'll get it next week...")
    ]
}

fileprivate enum ItemType {
    case delivered(method: ShippingMethod)
    case electronic
}

class PaymentViewController: UIViewController {

    private var payButton: PKPaymentButton = {
        let button = PKPaymentButton(paymentButtonType: .buy,
                                     paymentButtonStyle: .black)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.text = "Buy with"
        button.addTarget(self, action: #selector(pay(sender:)), for: .touchUpInside)
        return button
    }()
    
    let supportedPaymentNetworks: [PKPaymentNetwork] = [.visa, .masterCard, .amex, .JCB]
    let appleMerchantId = "merchant.com.adyen.flyscoot.test"
    
    let shippingCost: NSDecimalNumber = NSDecimalNumber(decimal: 2.0)
    var summaryItems: [PKPaymentSummaryItem] = {
        return [
            PKPaymentSummaryItem(label: "item 1", amount: 10.0),
            PKPaymentSummaryItem(label: "item 2", amount: 11.0),
            PKPaymentSummaryItem(label: "item 3", amount: 12.0)
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Apply Pay POC"
        self.view.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
    
        self.view.addSubview(payButton)
        NSLayoutConstraint.activate([
            payButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            payButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        /// Displaying summary items
        let shippingItem = PKPaymentSummaryItem(label: "Shipping", amount: shippingCost)
        summaryItems.append(shippingItem)
        
        let totalItem = PKPaymentSummaryItem(label: "Tigerspike",
                                             amount: summaryItems.reduce(0.0) { $1.amount.adding($0) })
        summaryItems.append(totalItem)
    }
    
    @objc func pay(sender: UIButton) {
        let request = PKPaymentRequest()
        request.merchantIdentifier = appleMerchantId
        request.supportedNetworks = supportedPaymentNetworks
        request.merchantCapabilities = .capability3DS
        request.countryCode = "SG"
        request.currencyCode = "SGD"
        request.paymentSummaryItems = summaryItems
        request.requiredBillingContactFields = Set<PKContactField>([.postalAddress, .phoneNumber, .phoneticName])
        
        request.requiredShippingContactFields =
            Set<PKContactField>([.name])
        
        var shippingMethods: [PKShippingMethod] = []
        ShippingMethod.ShippingMethodOptions.forEach { method in
            let shippingMethod = PKShippingMethod(label: method.title, amount: method.price)
            shippingMethod.identifier = method.title
            shippingMethod.detail = method.description
            shippingMethods.append(shippingMethod)
        }
        request.shippingMethods = shippingMethods
        
        guard let paymentSheetVC = PKPaymentAuthorizationViewController(paymentRequest: request) else {
            debugPrint("Cannot instantiate Payment VC")
            return
        }
        paymentSheetVC.delegate = self
        self.present(paymentSheetVC, animated: true, completion: nil)
    }
    
    private func total(type: ItemType, price: NSDecimalNumber) -> NSDecimalNumber {
        switch type {
        case .delivered(method: let method):
            return price.adding(method.price)
        case .electronic:
            return price
        }
    }
}

extension PaymentViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PKPayment,
                                            handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        let result = PKPaymentAuthorizationResult(status: .success, errors: nil)
        completion(result)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didSelectShippingContact contact: PKContact,
                                            handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void) {
        let contactUpdate = PKPaymentRequestShippingContactUpdate(errors: nil,
                                                                  paymentSummaryItems: summaryItems,
                                                                  shippingMethods: [])
        completion(contactUpdate)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didSelect shippingMethod: PKShippingMethod,
                                            handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        let method = ShippingMethod.ShippingMethodOptions.filter { method in
            method.title == shippingMethod.identifier
        }.first!
        
        /// Use method filter to reponds to method changes
        debugPrint(method)
        
        let methodUpdate = PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: summaryItems)
        completion(methodUpdate)
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
