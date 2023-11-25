//
//  NSView.Extension.swift
//  macapp
//
//  Created by 张小刚 on 2023/10/28.
//

import Cocoa

extension NSView {
    
    var backgroundColor: NSColor? {

        set {
            wantsLayer = true
            if let color = newValue {
                layer?.backgroundColor = color.cgColor
            } else {
                layer?.backgroundColor = nil
            }
        }
        
        get {
            if let cgColor = layer?.backgroundColor {
                return NSColor(cgColor: cgColor)
            }
            return nil
        }
    
    }
    
    var cornerRadius: CGFloat {
        
        set {
            wantsLayer = true
            layer?.cornerRadius = newValue
        }
        
        get {
            if let layer = self.layer {
                return layer.cornerRadius
            }
            return 0
        }
        
    }
    
}
