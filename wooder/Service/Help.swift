//
//  Help.swift
//  wooder
//
//  Created by 张小刚 on 2023/9/23.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation

class Help: Service {
    
    override class var aliasNames: [String] {
        return [
            "help",
        ]
    }
    
    override class var name: String {
        return "Help"
    }
    
    override var actions: [Action] {
        return [
            Action(aliasNames: ["service"], actionName:"serviceAction"),
        ]
    }
    
    /**
     - wooder help
     
     wooder support following services:
       - UerDefaults: wooder help ud
       - Sandbox: wooder help file
     */
    @objc func serviceAction() {
        guard let serviceName = request.arg1 else {
            noServiceHelp()
            return
        }
        let serviceType = Dispatcher.shared.dispatch(service: serviceName)
        guard serviceType != Help.self else {
            noServiceHelp()
            return
        }
        //service matched
        let service = serviceType.init(request: request)
        guard let actionName = request.arg2 else {
            serviceHelp(service:service)
            return
        }
        var targetAction: Action?
        let lowerActionName = actionName.lowercased()
        for action in service.actions {
            if action.aliasNames.contains(where: { name in
                return name.lowercased() == lowerActionName
            }) {
                targetAction = action
                break
            }
        }
        guard let action = targetAction else {
            serviceHelp(service:service)
            return
        }
        //action matched
        actionHelp(service:service, action: action, actionName: actionName)
    }
    
    func noServiceHelp() {
        let services = Dispatcher.shared.services
        print("🌿 wooder support following services:")
        for serviceType in services {
            guard serviceType != Help.self else {
                continue
            }
            let name = serviceType.name
            let aliasNames = serviceType.aliasNames
            if let first = aliasNames.first {
                print("  - \(name): wooder help \(first)")
            }
        }
    }
    
    /**
     - wooder help ud
     
     🌿 UesrDefaults support following actions:
       - get
         usage: wooder ud.get testkey
         alias: ["get", "read", "fetch"]
         help:  wooder help ud get
     */
    func serviceHelp(service: Service) {
        let type = type(of: service)
        print("🌿 \(type.name) support following actions:")
        for action in service.actions {
            guard let serviceName = type.aliasNames.first else {
                continue
            }
            if let first = action.aliasNames.first {
                print("  - \(first)")
                print("    usage: \(action.usage)")
                print("    alias: \(action.aliasNames)")
                print("    help:  wooder help \(serviceName) \(first)")
            }
        }
    }
    
    func actionHelp(service: Service, action: Action, actionName: String) {
        let type = type(of: service)
        let serviceName = type.name
        print("🌿 \(serviceName) \(actionName) help:")
        print("  usage: \(action.usage)")
        print("  alias: \(action.aliasNames)")
    }
    
}
