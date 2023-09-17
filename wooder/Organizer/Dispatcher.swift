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
    ]
    
    static let shared = Dispatcher()
    private init() {}
    
    func dispatch(service: String) -> Service.Type? {
        let target = services.first { item in
            return item.aliasNames.contains(service)
        }
        return target
    }
    
}
