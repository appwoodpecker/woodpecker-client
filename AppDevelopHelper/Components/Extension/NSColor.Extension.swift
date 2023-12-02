//
//  NSColor.Extension.swift
//  macapp
//
//  Created by 张小刚 on 2023/10/28.
//

import Cocoa

extension NSColor {
    
    @objc convenience init(hex: Int) {
        self.init(hex: hex, alpha: 1.0)
    }
    
    //0xAABBCC
    @objc convenience init(hex: Int, alpha: CGFloat) {
        let red = (hex & 0xFF0000) >> 16
        let green = (hex & 0x00FF00) >> 8
        let blue = hex & 0xFF
        let total: CGFloat = 255
        self.init(red: red.asCGFloat/total, green: green.asCGFloat/total, blue: blue.asCGFloat/total, alpha: alpha)
    }
    
}
