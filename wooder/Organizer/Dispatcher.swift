//
//  Dispatcher.swift
//  wooder
//
//  Created by 张小刚 on 2023/9/17.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation


struct Dispatcher {
    
    let services = [
        AppInfo.self,
        UserDefault.self,
        View.self,
        Sandbox.self,
        Device.self,
        Controller.self,
        Bundle.self,
        Help.self,
    ]
    
    static let shared = Dispatcher()
    private init() {}
    
    func dispatch(service: String) -> Service.Type {
        var result: Service.Type
        if let target = services.first(where: { item in
            return item.aliasNames.contains { name in
                return name.lowercased() == service.lowercased()
            }
        }) {
            result = target
        } else {
            result = services.last!
        }
        return result
    }
    
}
