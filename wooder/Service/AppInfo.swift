//
//  AppInfo.swift
//  wooder
//
//  Created by 张小刚 on 2023/9/17.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation
import AppKit

class AppInfo: Service {
    
    override class var aliasNames: [String] {
        return [
            "app",
        ]
    }
    
    override class var name: String {
        return "App"
    }
    
    override var actions: [Action] {
        return [
            Action(aliasNames: ["version","v"], actionName:"versionAction", usage: "wooder app.version"),
            Action(aliasNames: ["name","displayName"], actionName:"nameAction", usage: "wooder app.name"),
            Action(aliasNames: ["id","bundleId","idetifier"], actionName:"bundleIdAction", usage: "wooder app.bundleId"),
            Action(aliasNames: ["scheme","schemes","urlScheme","urlSchemes","schemeList"], actionName:"schemeAction", usage: "wooder app.scheme"),
            Action(aliasNames: ["font","fonts"], actionName:"fontAction", usage: "wooder app.font"),
            Action(aliasNames: ["infoDict","infoDictionary"], actionName:"infoDictAction", usage: "wooder app.infoDict"),
        ]
    }
    
    //wooder app.v
    @objc func versionAction() {
        guard let response = send(service:"adh.appinfo", action: "dashboard") else {
            return
        }
        guard let body = response.body else {
            retError()
            return
        }
        guard let version = body["version"] as? String,
              let build = body["build"] as? String else {
            retError()
            return
        }
        let msg = "\(version) (\(build))"
        retSuccess(msg)
    }
    
    @objc func nameAction() {
        guard let response = send(service:"adh.appinfo", action: "dashboard") else {
            return
        }
        guard let body = response.body else {
            retError()
            return
        }
        guard let name = body["appName"] as? String else {
            retError()
            return
        }
        retSuccess(name)
    }
    
    @objc func bundleIdAction() {
        guard let response = send(service:"adh.appinfo", action: "dashboard") else {
            return
        }
        guard let body = response.body else {
            retError()
            return
        }
        guard let name = body["bundleId"] as? String else {
            retError()
            return
        }
        retSuccess(name)
    }
    
    @objc func schemeAction() {
        guard let response = send(service:"adh.appinfo", action: "basicInfo") else {
            return
        }
        guard let body = response.body else {
            retError()
            return
        }
        guard let valueList = body["value"] as? [[String:Any]] else {
            retError()
            return
        }
        let targetItem = valueList.first { item in
            if let name = item["name"] as? String {
                return name == "URL Schemes"
            }
            return false
        }
        guard let targetItem = targetItem else {
            retError()
            return
        }
        guard let schemeList = targetItem["value"] as? [[String:Any]] else {
            retError()
            return
        }
        var schemes = [String]()
        for item in schemeList {
            if let value = item["value"] as? String, !value.isEmpty {
                schemes.append(value)
            }
        }
        let json = JsonUtil.json(schemes) ?? "[]"
        retSuccess(json)
    }
    
    @objc func fontAction() {
        guard let response = send(service:"adh.appinfo", action: "basicInfo") else {
            return
        }
        guard let body = response.body else {
            retError()
            return
        }
        guard let valueList = body["value"] as? [[String:Any]] else {
            retError()
            return
        }
        let targetItem = valueList.first { item in
            if let name = item["name"] as? String {
                return name == "Fonts"
            }
            return false
        }
        guard let targetItem = targetItem else {
            retError()
            return
        }
        guard let schemeList = targetItem["value"] as? [[String:Any]] else {
            retError()
            return
        }
        var schemes = [String]()
        for item in schemeList {
            if let value = item["value"] as? String, !value.isEmpty {
                schemes.append(value)
            }
        }
        let json = JsonUtil.json(schemes) ?? "[]"
        retSuccess(json)
    }
    
    //wooder app.infoDict key
    @objc func infoDictAction() {
        guard let response = send(service:"adh.appinfo", action: "infoDict") else {
            return
        }
        guard let body = response.body else {
            retError()
            return
        }
        if let key = request.arg1, !key.isEmpty {
            guard let value = body[key] else {
                retError("key not exists")
                return
            }
            retSuccess(value: value)
        } else {
            let msg = JsonUtil.json(body) ?? "{}"
            retSuccess(msg)
        }
    }
    
    
    
}
