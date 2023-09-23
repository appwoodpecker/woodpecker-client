//
//  Bundle.swift
//  wooder
//
//  Created by 张小刚 on 2023/9/23.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation
import AppKit


class Bundle: Service {
    
    override class var aliasNames: [String] {
        return [
            "bundle",
        ]
    }
    
    override class var name: String {
        return "Bundle"
    }
    
    override var actions: [Action] {
        return [
            Action(aliasNames: ["read","get","fetch"], actionName:"readFile", usage: "wooder bundle.read path-to-bundle-path -o path-to-dest-path"),
        ]
    }
    
    //wooder file Documents/file.data
    @objc func readFile() {
        guard let path = request.arg1 else {
            return
        }
        let url = URL(fileURLWithPath: path)
        let filename = url.lastPathComponent
        var destPath = ""
        if let outputPath = request.output {
            if ADHFileUtil.dirExists(atPath: outputPath) {
                destPath = outputPath.appending("/\(filename)")
            } else {
                destPath = outputPath
            }
        } else {
            guard let downloadDir = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true).first else {
                return
            }
            destPath = downloadDir.appending("/\(filename)")
        }
        var body = [AnyHashable:Any]()
        body["path"] = path
        guard let response = send(service: "adh.bundle", action: "readfile", body: body, payload: nil) else {
            return
        }
        if let fileData = response.payload {
            if ADHFileUtil.fileExists(atPath: destPath) {
                ADHFileUtil.deleteFile(atPath: destPath)
            }
            ADHFileUtil.save(fileData, atPath: destPath)
            let fileURL = URL(fileURLWithPath: destPath)
            NSWorkspace.shared.activateFileViewerSelecting([fileURL])
        } else {
            retError("file not exists: \(path)")
        }
    }
}
