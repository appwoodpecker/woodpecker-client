//
//  View.swift
//  wooder
//
//  Created by 张小刚 on 2023/9/17.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation

class View: Service {
    
    override class var aliasNames: [String] {
        return [
            "view",
        ]
    }
    
    override class var name: String {
        return "adh.view"
    }
    
    
    override func run() {
        var action = ""
        if let value = request.action {
            action = value
        }
        if action.isEmpty {
            action = "get"
        }
        if action == "get" {
            
        }
    }
    
}
