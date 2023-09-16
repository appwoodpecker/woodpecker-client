//
//  IPCServer.swift
//  Woodpecker
//
//  Created by 张小刚 on 2023/9/16.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation

@objcMembers
class IPCServer: NSObject {
    
    private lazy var listenThread = makeListenThread()
    
    public static let shared = IPCServer()
    private static let portId = "lifebetter.woodpecker.wooder" as CFString
    private let semaphore = DispatchSemaphore(value: 0)
    
    private var resultBody: [AnyHashable:Any]?
    
    override private init() {
        
    }
    
    public func setup() {
        listenThread.start()
    }
    
    @objc private func setupServerMessagePort() {
        Thread.current.name = "wooder.listenthread"
        let runloop = RunLoop.current
        let info = Unmanaged.passUnretained(self).toOpaque()
        var context = CFMessagePortContext(version: 0, info: info, retain: nil, release: nil, copyDescription: nil)
        guard let messagePort = CFMessagePortCreateLocal(nil, IPCServer.portId, callback, &context, nil) else {
            return
        }
        guard let source = CFMessagePortCreateRunLoopSource(nil, messagePort, 0) else {
            return
        }
        CFRunLoopAddSource(runloop.getCFRunLoop(), source, .commonModes)
        runloop.run()
    }
    
    private lazy var callback: CFMessagePortCallBack = { messagePort, messageID, cfData, info in
        IPCServer.shared.resultBody = nil
        guard let requestData = cfData as? Data,
              let json = String(data: requestData, encoding: .utf8) as? NSString,
              let requestBody = json.adh_jsonObject() as? NSDictionary else {
            return nil
        }
        let service = requestBody["service"] as? String ?? "adh.appinfo"
        let action = requestBody["action"] as? String ?? "basicinfo"
        guard let apiClient = AppContextManager.shared().topContext()?.apiClient() else {
            return nil
        }
        apiClient.request(withService: service, action: action) { body, payload in
            IPCServer.shared.resultBody = body
            IPCServer.shared.semaphore.signal()
        } onFailed: { error in
            IPCServer.shared.semaphore.signal()
        }
        IPCServer.shared.semaphore.wait()
        guard let resultBody = IPCServer.shared.resultBody as? NSDictionary,
              let resultJson = resultBody.adh_jsonPresentation() else {
            return nil
        }
        guard let resultData = resultJson.data(using: .utf8) else {
            return nil
        }
        return Unmanaged.passRetained(resultData as CFData)
    }
    
    private func makeListenThread() -> Thread {
        let thread = Thread(target: self, selector: #selector(setupServerMessagePort), object: nil)
        return thread
    }
    
}
