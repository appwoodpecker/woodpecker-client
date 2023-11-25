//
//  ViewLineView.swift
//  Woodpecker
//
//  Created by 张小刚 on 2023/11/25.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Cocoa

class ViewLineView: NSView {
    
    lazy var lineLayer = createLineLayer()
    
    let direction: Direction
    let dash: Bool
    
    init(direction: Direction, dash: Bool) {
        self.direction = direction
        self.dash = dash
        super.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.wantsLayer = true
        lineLayer.frame = self.bounds
        self.layer?.addSublayer(lineLayer)
    }
    
    override func layout() {
        super.layout()
        self.lineLayer.frame = self.bounds
        let layer = lineLayer
        let path = CGMutablePath()
        path.addRect(bounds)
        layer.path = path
    }
    
    
    func createLineLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.strokeColor = NSColor.red.cgColor
        layer.fillColor = nil
        layer.lineWidth = 0.5
        if dash {
            layer.lineDashPattern = [4, 4]
        } else {
            layer.lineDashPattern = nil
        }
        return layer
    }
    
}
