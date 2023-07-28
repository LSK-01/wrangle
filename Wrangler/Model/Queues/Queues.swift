//
//  Queues.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 04/08/2018.
//  Copyright © 2018 Luca Sarif-Kattan. All rights reserved.
//  https://stackoverflow.com/questions/42041894/what-is-the-difference-in-approach-to-create-dispatchqueue-swift3
// https://medium.com/the-traveled-ios-developers-guide/quality-of-service-849cd6dee1e

import Foundation

struct Queues{
    static let backgroundQueue = DispatchQueue.global(qos: .background)
    static let fastQueue = DispatchQueue.global(qos: .userInitiated)
    static let veryFastQueue = DispatchQueue.global(qos: .userInteractive)

   
}
