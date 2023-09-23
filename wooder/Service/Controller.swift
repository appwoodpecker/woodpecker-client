//
//  Controller.swift
//  wooder
//
//  Created by 张小刚 on 2023/9/23.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation

class Controller: Service {
    
    override class var aliasNames: [String] {
        return [
            "controller",
            "page",
        ]
    }
    
    override class var name: String {
        return "Controller"
    }
    
    override var actions: [Action] {
        return [
            Action(aliasNames: ["top","visible"], actionName:"topAction", usage: "wooder page.top"),
        ]
    }
    
    @objc func topAction() {
        guard let response = send(service:"adh.controller-hierarchy", action: "top") else {
            return
        }
        guard let code = response.body?["success"] as? Int, code == 1,
              let content = response.body?["content"] as? String, !content.isEmpty else {
            retError()
            return
        }
        retSuccess(content)
    }
}
