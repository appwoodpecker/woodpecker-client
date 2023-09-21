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
            Action(aliasNames: ["snapshot",], actionName:"snapshotAction"),
        ]
    }
    
    //wooder app.snapshot
    @objc func snapshotAction() {
        let response = send(service: "adh.device", action: "screenshot")
        guard let data = response.payload else {
            print("get payload failed")
            return
        }
        guard let downloadPath = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true).first else {
            return
        }
        print("download path\(downloadPath)")
        let dateText = ADHDateUtil.formatString(with: Date(), dateFormat: "YYYY-MM-dd HH.mm.ss")
        let filename = "Screenshot \(dateText).png"
        let filePath = downloadPath.appending("/\(filename)")
        let fileURL = URL(fileURLWithPath: filePath)
        try? data.write(to: fileURL)
        NSWorkspace.shared.activateFileViewerSelecting([fileURL])
    }
    
}
