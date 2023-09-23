//
//  JsonUtil.swift
//  wooder
//
//  Created by 张小刚 on 2023/9/23.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation


struct JsonUtil {
    
    static func json(_ object: Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object) else {
            return nil
        }
        let json = String(data: data, encoding: .utf8)
        return json
    }
    
    static func dict(_ json: String) -> [AnyHashable: Any]? {
        guard let data = json.data(using: .utf8) else {
            return nil
        }
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [AnyHashable: Any] else {
            return nil
        }
        return obj
    }
    
}
