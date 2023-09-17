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
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    private var response: IPCResponse?
    
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
        guard let messagePort = CFMessagePortCreateLocal(nil, IPC.portId, callback, &context, nil) else {
            return
        }
        guard let source = CFMessagePortCreateRunLoopSource(nil, messagePort, 0) else {
            return
        }
        CFRunLoopAddSource(runloop.getCFRunLoop(), source, .commonModes)
        runloop.run()
    }
    
    private lazy var callback: CFMessagePortCallBack = { messagePort, messageID, cfData, info in
        IPCServer.shared.response = nil
        guard let data = cfData as? Data,
              let request = IPCRequest.unarchive(data) else {
            return nil
        }
        let service = request.service
        let action = request.action
        let body = request.body
        let payload = request.payload
        guard let apiClient = AppContextManager.shared().topContext()?.apiClient() else {
            return nil
        }
        apiClient.request(withService: service, action: action, body: body, payload: payload, progressChanged: nil) { resBody, resPayload in
            let response = IPCResponse(body: resBody, payload: resPayload)
            IPCServer.shared.response = response
            IPCServer.shared.semaphore.signal()
        } onFailed: { error in
            IPCServer.shared.semaphore.signal()
        }
        IPCServer.shared.semaphore.wait()
        guard let response = IPCServer.shared.response,
              let responseData = response.archive() else {
            return nil
        }
        return Unmanaged.passRetained(responseData as CFData)
    }
    
    private func makeListenThread() -> Thread {
        let thread = Thread(target: self, selector: #selector(setupServerMessagePort), object: nil)
        return thread
    }
    
}
