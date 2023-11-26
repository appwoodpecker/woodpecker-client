//
//  ViewMeasure.swift
//  Woodpecker
//
//  Created by 张小刚 on 2023/11/21.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation

//边
enum Border {
    case min
    case max
}

enum Direction {
    case horizonal
    case vertical
}

struct Joint {
    let border1: Border
    let border2: Border
}

struct ViewMeasure {
    static func caculateXJoint(r1: CGRect, r2: CGRect) -> [Joint] {
        var result: [Joint] = []
        if r2.maxX < r1.minX {
            result.append(Joint(border1: .min, border2: .max))
        } else if r2.maxX < r1.maxX {
            result.append(Joint(border1: .min, border2: .min))
            if r2.minX > r1.minX {
                result.append(Joint(border1: .max, border2: .max))
            }
        } else if r2.maxX > r1.maxX {
            if (r2.minX < r1.minX) {
                result.append(Joint(border1: .min, border2: .min))
                result.append(Joint(border1: .max, border2: .max))
            } else if r2.minX < r1.maxX {
                result.append(Joint(border1: .max, border2: .max))
            } else {
                result.append(Joint(border1: .max, border2: .min))
            }
        }
        return result
    }

    static func caculateYJoint(r1: CGRect, r2: CGRect) -> [Joint] {
        var result = [Joint]()
        if r2.maxY < r1.minY {
            result.append(Joint(border1: .min, border2: .max))
        } else if r2.maxY < r1.maxY {
            result.append(Joint(border1: .min, border2: .min))
            if r2.minY > r1.minY {
                result.append(Joint(border1: .max, border2: .max))
            }
        } else if r2.maxY > r1.maxY {
            if (r2.minY < r1.minY) {
                result.append(Joint(border1: .min, border2: .min))
                result.append(Joint(border1: .max, border2: .max))
            } else if r2.minY < r1.maxY {
                result.append(Joint(border1: .max, border2: .max))
            } else {
                result.append(Joint(border1: .max, border2: .min))
            }
        }
        return result
    }
    
}
