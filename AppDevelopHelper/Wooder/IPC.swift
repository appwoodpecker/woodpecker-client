//
//  ADHIPC.swift
//  wooder
//
//  Created by 张小刚 on 2023/9/16.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation

struct IPC {
    
    public static let portId = "lifebetter.woodpecker.wooder" as CFString
    
}

struct IPCRequest {
    let service: String
    let action: String
    let body: [AnyHashable:Any]?
    let payload: Data?
    
    func archive() -> Data? {
        var dict = [AnyHashable:Any]()
        dict["service"] = service
        dict["action"] = action
        if let body = body {
            dict["body"] = body
        }
        if let payload = payload {
            dict["payload"] = payload
        }
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: false) else {
            return nil
        }
        return data
    }
    
    static func unarchive(_ data: Data) -> IPCRequest? {
        guard let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AnyHashable:Any] else {
            return nil
        }
        guard let service = dict["service"] as? String,
                let action = dict["action"] as? String else {
            return nil
        }
        let body = dict["body"] as? [AnyHashable:Any]
        let payload = dict["payload"] as? Data
        let request = IPCRequest(service: service, action: action, body: body, payload: payload)
        return request
    }
    
}

struct IPCResponse {
    let body: [AnyHashable:Any]?
    let payload: Data?
    
    func archive() -> Data? {
        var dict = [AnyHashable:Any]()
        if let body = body {
            dict["body"] = body
        }
        if let payload = payload {
            dict["payload"] = payload
        }
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: false) else {
            return nil
        }
        return data
    }
    
    static func unarchive(_ data: Data) -> IPCResponse? {
        guard let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AnyHashable:Any] else {
            return nil
        }
        let body = dict["body"] as? [AnyHashable:Any]
        let payload = dict["payload"] as? Data
        let response = IPCResponse(body: body, payload: payload)
        return response
    }
    
}
