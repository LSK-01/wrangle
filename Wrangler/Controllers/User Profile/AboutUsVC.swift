//
//  AboutUsVC.swift
//  Wrangler
//
//  Created by god himself on 30/07/2021.
//  Copyright © 2021 Luca Sarif-Kattan. All rights reserved.
//

import UIKit
//import PayPalCheckout

class AboutVC: UIViewController{
    
    @IBOutlet weak var bugReport: UITextView!
    
    @IBAction func submitBug(_ sender: Any) {
  

        Database.db.collection("bugs").addDocument(data: ["bug description": bugReport.text ?? "", "date submitted": Date.getCurrentDate(), "user": User.details.uid, "username": User.details.username])
        bugReport.text = ""
        Alert.alert(message: "Thank you for improving Wrangle", title: "Your bug was submitted")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bugReport.text = ""
        bugReport.backgroundColor = DesignConstants.mainPurple.withAlphaComponent(0.3)
//        let paymentButton = PayPalButton()
//        view.addSubview(paymentButton)
//        paymentButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate(
//            [
//                paymentButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//                paymentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//            ]
//        )
//configurePayPalCheckout()
        
    }
    
//    func configurePayPalCheckout() {
//            Checkout.setCreateOrderCallback { createOrderAction in
//                let amount = PurchaseUnit.Amount(currencyCode: .gbp, value: "3.00")
//                let purchaseUnit = PurchaseUnit(amount: amount)
//                let order = OrderRequest(intent: .capture, purchaseUnits: [purchaseUnit])
//
//                createOrderAction.create(order: order)
//            }
//
//            Checkout.setOnApproveCallback { approval in
//                 approval.actions.capture { (response, error) in
//                    print("Order successfully captured: \(response?.data)")
//                }
//            }
//
//        }
}
