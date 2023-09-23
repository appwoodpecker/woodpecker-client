//
//  Sandbox.swift
//  wooder
//
//  Created by 张小刚 on 2023/9/18.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation
import AppKit

class Sandbox: Service {
    
    override class var name: String {
        return "Sandbox"
    }
    
    override class var aliasNames: [String] {
        return [
            "sandbox", "file", "fb",
        ]
    }
    
    override var actions: [Action] {
        return [
            Action(aliasNames: ["read","get","fetch"], actionName:"readFile"),
            Action(aliasNames: ["write", "save", "update"], actionName:"writeFile"),
            Action(aliasNames: ["remove", "delete", "del"], actionName:"removeFile"),
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
        let response = send(service: "adh.sandbox", action: "readfile", body: body, payload: nil)
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
    
    @objc func writeFile() {
        guard let path = request.arg1 else {
            return
        }
        guard let inputPath = request.input else {
            return
        }
        let fileURL = URL(fileURLWithPath: inputPath)
        guard let fileData = try? Data.init(contentsOf: fileURL) else {
            return
        }
        var body = [AnyHashable:Any]()
        body["path"] = path
        let response = send(service: "adh.sandbox", action: "writefile", body: body, payload: fileData)
        guard let success = response.body?["success"] as? Int, success == 1 else {
            retError()
            return
        }
        retSuccess()
    }
    
    @objc func removeFile() {
        guard let path = request.arg1 else {
            return
        }
        var isDir = false
        if path.hasSuffix("/") {
            isDir = true
        }
        var body = [AnyHashable:Any]()
        body["path"] = path
        body["isDir"] = isDir
        let response = send(service: "adh.sandbox", action: "removefile", body: body)
        guard let success = response.body?["success"] as? Int, success == 1 else {
            retError()
            return
        }
        retSuccess()
    }
    
}
