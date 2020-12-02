//
//  MiscClasses.swift
//  Vault
//
//  Created by Ahmed Yahya on 9/21/18.
//  Copyright © 2018 Ahmed Yahya. All rights reserved.
//

import Foundation
import UIKit

class TextField_NoPaste: UITextField {
    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) || action == #selector(paste(_:)) {
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
}
