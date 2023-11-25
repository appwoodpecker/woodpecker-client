//
//  NSTextField.Extension.swift
//  macapp
//
//  Created by 张小刚 on 2023/10/28.
//

import Cocoa

extension NSTextField {
    
    static func createLabel() -> NSTextField {
        let textField = NSTextField()
        textField.isEditable = false
        textField.alignment = .left
        textField.isBordered = false
        textField.drawsBackground = false
        textField.isSelectable = true
        textField.maximumNumberOfLines = 1
        return textField
    }
    
    var text: String? {
        
        set {
            if let value = newValue {
                self.stringValue = value
            } else {
                self.stringValue = ""
            }
        }
        
        get {
            return self.stringValue
        }
        
    }
    
}
