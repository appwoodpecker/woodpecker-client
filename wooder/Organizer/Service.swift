//
//  Service.swift
//  wooder
//
//  Created by 张小刚 on 2023/9/17.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation

class Service {

    struct Request {
        let action: String?
        let arg1: String?
        let arg2: String?
        let input: String?
        let output: String?
    }
    
    let request: Request
    
    required init(request: Request) {
        self.request = request
    }
    
    class var name: String {
        return ""
    }
    
    class var aliasNames: [String] {
        return []
    }

    func validate() -> (Bool, String?) {
        return (true, nil)
    }
    
    func run() {
        
    }
    
    func send(service:String, action: String, body: [AnyHashable:Any]? = nil, payload:Data? = nil) -> IPCResponse {
        let request = IPCRequest(service: service, action: action, body: body, payload: payload)
        if let response = IPCClient.shared.request(request) {
            return response
        } else {
            return IPCResponse(body: [AnyHashable:Any](), payload: nil)
        }
    }
    
}
