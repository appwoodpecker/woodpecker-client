//
//  UserDefaults.swift
//  wooder
//
//  Created by 张小刚 on 2023/9/16.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation

class UserDefault: Service {
    
    override class var aliasNames: [String] {
        return [
            "ud",
            "userdefault",
            "userdefaults"
        ]
    }
    
    override class var name: String {
        return "adh.userdefaults"
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
            getAction()
        } else if action == "update" {
            updateAction()
        }
    }
    
    //MARK: - get ud.get key
    func getAction() {
        if let key = request.arg1, !key.isEmpty {
            //get key
            var body = [AnyHashable:Any]()
            body["key"] = key
            let response = send(service:"adh.userdefaults", action: "requestData", body: body, payload: nil)
            guard let payload = response.payload else {
                print("key not found 1")
                return
            }
            guard let dict = payload.dictUnarchived() else {
                print("payload empty")
                return
            }
            if let value = dict[key] {
                print("\(value)")
            } else {
                print("key not found 2")
            }
        } else {
            //get all
            let response = send(service:"adh.userdefaults", action: "requestData", body: nil, payload: nil)
            guard let payload = response.payload else {
                print("key not found 1")
                return
            }
            guard let dict = payload.dictUnarchived() else {
                print("payload empty")
                return
            }
            print("\(dict)")
        }
    }
    
    func updateAction() {
        guard let key = request.arg1, !key.isEmpty,
              let value = request.arg2 else {
            return
        }
        var body = [AnyHashable:Any]()
        body["key"] = key
        let payload = value.archive()
        let response = send(service:"adh.userdefaults", action: "updateValue", body: body, payload: payload)
        guard let success = response.body?["success"] as? Int,
                success == 1 else {
            print("update failed")
            return
        }
        print("update succeed")
    }
    
    
}
