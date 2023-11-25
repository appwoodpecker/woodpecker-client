//
//  NSColor.Extension.swift
//  macapp
//
//  Created by 张小刚 on 2023/10/28.
//

import Cocoa

extension NSColor {
    
    //0xAABBCC
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = (hex & 0xFF0000) >> 16
        let green = (hex & 0x00FF00) >> 8
        let blue = hex & 0xFF
        let total: CGFloat = 255
        self.init(red: red.asCGFloat/total, green: green.asCGFloat/total, blue: blue.asCGFloat/total, alpha: alpha)
    }
    
}
