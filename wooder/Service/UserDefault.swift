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
        return "UesrDefaults"
    }
    
    override var actions: [Action] {
        return [
            Action(aliasNames: ["get","read","fetch"], actionName:"getAction"),
            Action(aliasNames: ["set", "update", "write","save"], actionName:"updateAction"),
            Action(aliasNames: ["remove", "delete"], actionName:"removeAction"),
        ]
    }
    
    //MARK: - get ud.get key
    @objc func getAction() {
        if let key = request.arg1, !key.isEmpty {
            //get key
            var body = [AnyHashable:Any]()
            body["key"] = key
            let response = send(service:"adh.userdefaults", action: "requestData", body: body, payload: nil)
            guard let payload = response.payload else {
                retError("key not exists")
                return
            }
            guard let dict = payload.dictUnarchived() else {
                retError()
                return
            }
            if let value = dict[key] {
                retSuccess("\(value)")
            } else {
                retError("key not exists")
            }
        } else {
            //get all
            let response = send(service:"adh.userdefaults", action: "requestData", body: nil, payload: nil)
            guard let payload = response.payload else {
                retError("empty")
                return
            }
            guard let dict = payload.dictUnarchived() else {
                retError("empty")
                return
            }
            retSuccess("\(dict)")
        }
    }
    
    @objc func updateAction() {
        guard let key = request.arg1, !key.isEmpty,
              let value = request.arg2 else {
            return
        }
        var body = [AnyHashable:Any]()
        body["key"] = key
        let payload = value.archive()
        let response = send(service:"adh.userdefaults", action: "updateValue", body: body, payload: payload)
        guard let _ = response.body?["success"] as? Int else {
            retError()
            return
        }
        retSuccess()
    }
    
    @objc func removeAction() {
        guard let key = request.arg1, !key.isEmpty else {
            return
        }
        var body = [AnyHashable:Any]()
        body["key"] = key
        let response = send(service:"adh.userdefaults", action: "remove", body: body)
        guard let _ = response.body?["success"] as? Int else {
            retError()
            return
        }
        retSuccess()
    }
    
}
