//
//  SwiftMessagesSegue.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 14/10/2018.
//  Copyright © 2018 Luca Sarif-Kattan. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages

class CustomSwiftMessages: SwiftMessagesSegue {
    override public init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .bottomCard)
        dimMode = .blur(style: .dark, alpha: 0.9, interactive: true)
        messageView.configureNoDropShadow()
    }
}
