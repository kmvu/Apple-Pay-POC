//
//  ViewController.swift
//  Apple_pay_POC
//
//  Created by Khang Vu on 7/3/19.
//  Copyright © 2019 Tigerspike. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    private var payButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = UIColor(red:0.43, green:0.30, blue:0.25, alpha:1.0)
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(payButton)
        NSLayoutConstraint.activate([
            payButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            payButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            payButton.widthAnchor.constraint(equalToConstant: 150.0),
            payButton.heightAnchor.constraint(equalToConstant: 60.0)
        ])
    }
}

