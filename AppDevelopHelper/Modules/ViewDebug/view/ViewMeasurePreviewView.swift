//
//  ViewMeasurePreviewView.swift
//  Woodpecker
//
//  Created by 张小刚 on 2023/11/22.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Cocoa
import SnapKit

@objcMembers
class ViewMeasurePreviewView: NSView {
    
    struct ScaleFactor {
        let width: CGFloat
        let height: CGFloat
        let centerX: CGFloat
        let centerY: CGFloat
    }
    
    lazy var backgroundView = createBackgroundView()
    lazy var frameView = createFrameView()
    lazy var targetView = createTargetView()
    lazy var mainView = createMainView()
    var measureViews = [NSView]()
    
    var rootNode: ADHViewNode?
    var mainNode: ADHViewNode?
    var targetNode: ADHViewNode?
            
    struct K {
        static let frameSize: CGFloat = 240
        static let borderSize: CGFloat = 8
    }
    
    static func createView() -> ViewMeasurePreviewView {
        let view = ViewMeasurePreviewView(frame: .zero)
        return view
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addLayoutConstraint() {
        self.snp.makeConstraints { make in
            let edge: CGFloat = 20
            make.top.equalToSuperview().inset(30+edge)
            make.right.equalToSuperview().inset(edge)
        }
    }
    
    func setupUI() {
        self.clipsToBounds = true
        addSubview(backgroundView)
        addSubview(frameView)
        frameView.addSubview(mainView)
        frameView.addSubview(targetView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        frameView.snp.makeConstraints { make in
            make.width.equalTo(0)
            make.height.equalTo(0)
            make.edges.equalToSuperview().inset(K.borderSize)
        }
    }
    
    func updateFrameUI() {
        guard let node = self.rootNode else {
            return
        }
        let frame = node.frame()
        let width = frame.width
        let height = frame.height
        var frameWidth = K.frameSize
        var frameHeight = K.frameSize
        if width < height {
            frameHeight = Int(K.frameSize * (height/width)).asCGFloat
        } else {
            frameWidth =  Int(K.frameSize * (width/height)).asCGFloat
        }
        frameView.snp.updateConstraints { make in
            make.width.equalTo(frameWidth)
            make.height.equalTo(frameHeight)
        }
    }
  
    
    func updateUI() {
        measureViews.forEach { view in
            view.removeFromSuperview()
        }
        measureViews.removeAll()
        if let mainNode = mainNode {
            mainView.isHidden = false
            let mainFactor = caculateNodeScaleFactor(mainNode.frameInWindow())
            mainView.snp.remakeConstraints { make in
                make.width.equalToSuperview().multipliedBy(mainFactor.width)
                make.height.equalToSuperview().multipliedBy(mainFactor.height)
                make.centerX.equalToSuperview().multipliedBy(mainFactor.centerX)
                make.centerY.equalToSuperview().multipliedBy(mainFactor.centerY)
            }
        } else {
            mainView.isHidden = true
        }
        if let targetNode = self.targetNode {
            targetView.isHidden = false
            let targertFactor = caculateNodeScaleFactor(targetNode.frameInWindow())
            targetView.snp.remakeConstraints { make in
                make.width.equalToSuperview().multipliedBy(targertFactor.width)
                make.height.equalToSuperview().multipliedBy(targertFactor.height)
                make.centerX.equalToSuperview().multipliedBy(targertFactor.centerX)
                make.centerY.equalToSuperview().multipliedBy(targertFactor.centerY)
            }
            updateMeasureUI()
        } else {
            targetView.isHidden = true
        }
    }
    
    func updateMeasureUI() {
        guard let mainNode = mainNode,
              let targetNode = targetNode else {
            return
        }
        let frame1 = cgRectFromFrame(frame:mainNode.frameInWindow())
        let frame2 = cgRectFromFrame(frame:targetNode.frameInWindow())
        let xJoints = ViewMeasure.caculateXJoint(r1: frame1, r2: frame2)
        for joint in xJoints {
            addMeasureJoint(frame1: frame1, frame2: frame2, joint: joint, direction: .horizonal)
        }
        let yJoints = ViewMeasure.caculateYJoint(r1: frame1, r2: frame2)
        for joint in yJoints {
            addMeasureJoint(frame1: frame1, frame2: frame2, joint: joint, direction: .vertical)
        }
        
    }
    
    func addMeasureJoint(frame1: CGRect, frame2: CGRect, joint: Joint, direction: Direction) {
        if direction == .horizonal {
            let startX = joint.border1 == .min ? frame1.minX : frame1.maxX
            let startY = frame1.midY
            let endX = joint.border2 == .min ? frame2.minX : frame2.maxX
            let endY = startY
            //guide line
            let guideX = min(startX, endX)
            let guideWidth = abs(endX - startX)
            if guideWidth < 1 {
                return
            }
            let rect = CGRect(x: guideX, y: startY, width:guideWidth, height: 0)
            let line = addGuideLine(rect: rect, direction:.horizonal)
            if endY < frame2.minY || endY > frame2.maxY {
                //dash guide line
                let guideX = endX
                var guideStartY: CGFloat = 0
                var guideEndY: CGFloat = 0
                if endY < frame2.minY {
                    guideStartY = endY
                    guideEndY = frame2.minY
                } else {
                    guideStartY = frame2.maxY
                    guideEndY = endY
                }
                let guideRect = CGRect(x: guideX, y: guideStartY, width: 0, height: guideEndY - guideStartY)
                addGuideLine(rect: guideRect, direction: .vertical, dash: true)
            }
            //measure label
            let label = "\(Int(rect.width))"
            addGuideLabel(label: label, relative:line, direction:.horizonal)
        } else {
            let startX = frame1.midX
            let startY = joint.border1 == .min ? frame1.minY : frame1.maxY
            let endX = startX
            let endY = joint.border2 == .min ? frame2.minY : frame2.maxY
            //guide line
            let guideY = min(startY, endY)
            let guideHeight = abs(endY - startY)
            if guideHeight < 1 {
                return
            }
            let rect = CGRect(x: startX, y: guideY, width: 0, height: guideHeight)
            let line = addGuideLine(rect: rect, direction: .vertical)
            if endX < frame2.minX || endX > frame2.maxX {
                //dash guide line
                let guideY = endY
                var guideStartX: CGFloat = 0
                var guideEndX: CGFloat = 0
                if endX < frame2.minX {
                    guideStartX = endX
                    guideEndX = frame2.minX
                } else {
                    guideStartX = frame2.maxX
                    guideEndX = endX
                }
                let guideRect = CGRect(x: guideStartX, y:guideY , width: guideEndX - guideStartX, height: 0)
                addGuideLine(rect: guideRect, direction:.horizonal, dash: true)
            }
            //measure label
            let label = "\(Int(rect.height))"
            addGuideLabel(label: label, relative:line, direction:.vertical)
        }
    }
    
    @discardableResult
    func addGuideLine(rect: CGRect, direction: Direction, dash: Bool = false) -> NSView {
        let line = ViewLineView(direction: direction, dash: dash)
        let frame = adhFrameFromRect(rect: rect)
        frameView.addSubview(line)
        let factor = caculateNodeScaleFactor(frame)
        if direction == .horizonal {
            line.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(factor.width)
                make.height.equalTo(1)
                make.centerX.equalToSuperview().multipliedBy(factor.centerX)
                make.centerY.equalToSuperview().multipliedBy(factor.centerY)
            }
        } else {
            line.snp.makeConstraints { make in
                make.width.equalTo(1)
                make.height.equalToSuperview().multipliedBy(factor.height)
                make.centerX.equalToSuperview().multipliedBy(factor.centerX)
                make.centerY.equalToSuperview().multipliedBy(factor.centerY)
            }
        }
        measureViews.append(line)
        return line
    }
    
    func addGuideLabel(label: String, relative line: NSView, direction: Direction) {
        let textfield = NSTextField.createLabel()
        textfield.font = NSFont.systemFont(ofSize: 10.0)
        textfield.textColor = .white
        textfield.wantsLayer = true
        if direction == .vertical {
            textfield.layer?.backgroundColor = NSColor.systemRed.cgColor
        } else {
            textfield.layer?.backgroundColor = NSColor.systemBlue.cgColor
        }
        textfield.cornerRadius = 4.0
        textfield.alignment = .center
        textfield.stringValue = label
        textfield.toolTip = label
        frameView.addSubview(textfield)
        if direction == .horizonal {
            textfield.snp.makeConstraints { make in
                make.top.equalTo(line).offset(4)
                make.centerX.equalTo(line)
            }
        } else {
            textfield.snp.makeConstraints { make in
                make.left.equalTo(line.snp.right).offset(4)
                make.centerY.equalTo(line)
            }
        }
        measureViews.append(textfield)
    }
    
}

extension ViewMeasurePreviewView {
    
    func caculateNodeScaleFactor(_ frame: ADH_FRAME) -> ScaleFactor {
        guard let frameNode = self.rootNode else {
            return ScaleFactor(width: 0, height: 0, centerX: 0, centerY: 0)
        }
        let frameWidth = frameNode.frame().width
        let frameHeight = frameNode.frame().height
        let widthScale = frame.width / frameWidth
        let heightScale = frame.height / frameHeight
        let centerXScale = max((frame.centerX / frameWidth) * 2, 0.01)
        let centerYScale = max((frame.centerY / frameHeight) * 2, 0.01)
        return ScaleFactor(width: widthScale, height: heightScale, centerX: centerXScale, centerY: centerYScale)
    }
    
    func cgRectFromFrame(frame: ADH_FRAME) -> CGRect {
        let x = frame.centerX - frame.width/2
        let y = frame.centerY - frame.height/2
        return CGRect(x: x, y: y, width: frame.width, height: frame.height)
    }
    
    func adhFrameFromRect(rect: CGRect) -> ADH_FRAME {
        let centerX = rect.minX + rect.width/2
        let centerY = rect.minY + rect.height/2
        return ADH_FRAME(centerX: centerX, centerY: centerY, width: rect.width, height: rect.height)
    }
    
}

extension ViewMeasurePreviewView {
    
    func createBackgroundView() -> NSView {
        let view = NSView()
        view.backgroundColor = NSColor(hex: 0x000000)
        view.cornerRadius = K.borderSize/2
        return view
    }
    
    func createFrameView() -> NSView {
        let view = NSView()
        view.backgroundColor = .white
        view.cornerRadius = 2
        view.clipsToBounds = false
        return view
    }
    
    func createMainView() -> NSView {
        let view = NSView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.5)
        return view
    }
    
    func createTargetView() -> NSView {
        let view = NSView()
        view.backgroundColor = .systemRed.withAlphaComponent(0.3)
        return view
    }
    
}



