//
//  IPCClient.swift
//  wooder
//
//  Created by 张小刚 on 2023/9/16.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation

class IPCClient {
    
    static let shared = IPCClient()
    private init() {}
    
    func request(_ request: IPCRequest) -> IPCResponse? {
        guard let data = request.archive() else {
            print("🌿 request archive failed")
            return nil
        }
        guard let messagePort = CFMessagePortCreateRemote(nil, IPC.portId) else {
            print("🌿 please ensure woodpecker client is running")
            return nil
        }
        var unmanagedData: Unmanaged<CFData>? = nil
        let status = CFMessagePortSendRequest(messagePort, 0, data as CFData, 30, 30, CFRunLoopMode.defaultMode.rawValue, &unmanagedData)
        let cfData = unmanagedData?.takeRetainedValue()
        if status == kCFMessagePortSuccess {
            if let data = cfData as Data? {
                if let response = IPCResponse.unarchive(data) {
                    return response
                } else {
                    print("🌿 please ensure woodpecker client and app is connected, or restart woopdecker client")
                    return nil
                }
            }
        }
        print("🌿 woodpecker client response failed, please try later")
        return nil
    }
    
}


