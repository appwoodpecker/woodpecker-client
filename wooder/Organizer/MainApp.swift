//
//  MainApp.swift
//  wooder
//
//  Created by 张小刚 on 2023/9/16.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation
import ArgumentParser


/**
 wooder ud.get key
 wooder ud.update key value
 */
@main
struct MainApp: ParsableCommand {
    
    @Argument(help: "")
    var cmd: String
    
    @Argument
    var arg1: String?
    
    @Argument
    var arg2: String?
    
    @Option(name: [.short, .customLong("input")])
    var input: String?
    
    @Option(name: [.short, .customLong("output")])
    var output: String?

    func run() {
//        print("[action]:\(cmd), [arg1]:\(arg1 ?? ""), [arg2]: \(arg2 ?? "") [-i]: \(input ?? "") [-o]: \(output ?? "")")
        var service = ""
        var action = ""
        let comps = cmd.components(separatedBy: ".")
        if comps.count > 0 {
            service = comps[0]
        }
        if comps.count > 1 {
            action = comps[1]
        }
        let request = Service.Request(action: action, arg1: arg1, arg2: arg2, input: input, output: output)
        let serviceClass = Dispatcher.shared.dispatch(service: service)
        let app = serviceClass.init(request: request)
        app.run()
    }
    
}
