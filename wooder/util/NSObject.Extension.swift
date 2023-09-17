//
//  NSObject.Extension.swift
//  wooder
//
//  Created by 张小刚 on 2023/9/17.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation

extension Data {
    
    func dictUnarchived() -> [AnyHashable:Any]? {
        guard let dict = NSKeyedUnarchiver.unarchiveObject(with: self) as? [AnyHashable:Any] else {
            return nil
        }
        return dict
    }
    
}

extension String {
    
    func archive() -> Data? {
        let data = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        return data
    }
    
}


