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
            return nil
        }
        guard let messagePort = CFMessagePortCreateRemote(nil, IPC.portId) else {
            return nil
        }
        var unmanagedData: Unmanaged<CFData>? = nil
        let status = CFMessagePortSendRequest(messagePort, 0, data as CFData, 30, 30, CFRunLoopMode.defaultMode.rawValue, &unmanagedData)
        let cfData = unmanagedData?.takeRetainedValue()
        if status == kCFMessagePortSuccess {
            if let data = cfData as Data? {
               return IPCResponse.unarchive(data)
            }
        }
        return nil
    }
    
}


