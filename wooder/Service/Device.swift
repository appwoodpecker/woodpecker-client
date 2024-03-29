//
//  Device.swift
//  wooder
//
//  Created by 张小刚 on 2023/9/23.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation
import AppKit

class Device: Service {
    
    override class var aliasNames: [String] {
        return [
            "device", "dv",
        ]
    }
    
    override class var name: String {
        return "Device"
    }
    
    override var actions: [Action] {
        return [
            Action(aliasNames: ["name"], actionName:"nameAction", usage: "wooder device.name"),
            Action(aliasNames: ["snapshot"], actionName:"snapshotAction", usage: "wooder device.snapshot"),
            Action(aliasNames: ["os","version","v","systemVersion"], actionName:"versionAction", usage: "wooder device.os"),
            Action(aliasNames: ["model"], actionName:"modelAction", usage: "wooder device.model"),
            Action(aliasNames: ["resolution","pixel"], actionName:"resolutionAction", usage: "wooder device.resolution"),
            Action(aliasNames: ["timezone"], actionName:"timezoneAction", usage: "wooder device.timezone"),
            Action(aliasNames: ["locale"], actionName:"localeAction", usage: "wooder device.locale"),
            Action(aliasNames: ["calendar"], actionName:"calendarAction", usage: "wooder device.calendar"),
            Action(aliasNames: ["ip"], actionName:"ipAction", usage: "wooder device.ip")
        ]
    }
    
    //wooder app.snapshot
    @objc func snapshotAction() {
        guard let response = send(service: "adh.device", action: "screenshot") else {
            return
        }
        guard let data = response.payload else {
            retError()
            return
        }
        guard let downloadPath = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true).first else {
            return
        }
        let dateText = ADHDateUtil.formatString(with: Date(), dateFormat: "YYYY-MM-dd HH.mm.ss")
        let filename = "Screenshot \(dateText).png"
        let filePath = downloadPath.appending("/\(filename)")
        let fileURL = URL(fileURLWithPath: filePath)
        try? data.write(to: fileURL)
        NSWorkspace.shared.activateFileViewerSelecting([fileURL])
    }
    
    @objc func versionAction() {
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
                return name == "System Name"
            }
            return false
        }
        guard let targetItem = targetItem else {
            retError()
            return
        }
        guard let value = targetItem["value"] as? String else {
            retError()
            return
        }
        retSuccess(value)
    }
    
    @objc func modelAction() {
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
                return name == "Device Model"
            }
            return false
        }
        guard let targetItem = targetItem else {
            retError()
            return
        }
        guard let value = targetItem["value"] as? String else {
            retError()
            return
        }
        retSuccess(value)
    }
    
    @objc func nameAction() {
        guard let response = send(service:"adh.appinfo", action: "dashboard") else {
            return
        }
        guard let body = response.body else {
            retError()
            return
        }
        guard let sysVersion = body["deviceName"] as? String else {
            retError()
            return
        }
        retSuccess(sysVersion)
    }
    
    @objc func resolutionAction() {
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
                return name == "Resolution"
            }
            return false
        }
        guard let targetItem = targetItem else {
            retError()
            return
        }
        guard let value = targetItem["value"] as? String else {
            retError()
            return
        }
        retSuccess(value)
    }
    
    @objc func timezoneAction() {
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
                return name == "Timezone"
            }
            return false
        }
        guard let targetItem = targetItem else {
            retError()
            return
        }
        guard let value = targetItem["value"] as? String else {
            retError()
            return
        }
        retSuccess(value)
    }
    
    @objc func localeAction() {
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
                return name == "Locale"
            }
            return false
        }
        guard let targetItem = targetItem else {
            retError()
            return
        }
        guard let value = targetItem["value"] as? String else {
            retError()
            return
        }
        retSuccess(value)
    }
    
    @objc func calendarAction() {
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
                return name == "Calendar"
            }
            return false
        }
        guard let targetItem = targetItem else {
            retError()
            return
        }
        guard let value = targetItem["value"] as? String else {
            retError()
            return
        }
        retSuccess(value)
    }
    
    @objc func ipAction() {
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
                return name == "Network"
            }
            return false
        }
        guard let targetItem = targetItem else {
            retError()
            return
        }
        guard let value = targetItem["value"] as? String else {
            retError()
            return
        }
        retSuccess(value)
    }
    
    
}
