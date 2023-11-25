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
    
    lazy var frameView = createFrameView()
    lazy var targetView = createTargetView()
    lazy var mainView = createMainView()
    var measureViews = [NSView]()
    var rootNode: ADHViewNode? {
        didSet {
            updateFrameUI()
        }
    }
    
    var mainNode: ADHViewNode? {
        didSet {
            updateUI()
        }
    }
    
    var targetNode: ADHViewNode? {
        didSet {
            updateUI()
        }
    }
    
    var containerSize: CGSize = .zero
    var windowSize: CGSize = .zero
        
    struct K {
        static let frameSize: CGFloat = 240
        static let borderSize: CGFloat = 16
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
    
    func setupUI() {
        self.backgroundColor = NSColor(hex: 0x8FCD70)
        addSubview(frameView)
        frameView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(0)
            make.height.equalTo(0)
        }
        frameView.addSubview(mainView)
        frameView.addSubview(targetView)
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
        let contentWidth = frameWidth + K.borderSize*2
        let contentHeight = frameHeight + K.borderSize*2
        self.containerSize = CGSize(width: contentWidth, height: contentHeight)
        self.windowSize = CGSize(width: frameWidth, height: frameHeight)
        frameView.snp.updateConstraints { make in
            make.width.equalTo(frameWidth)
            make.height.equalTo(frameHeight)
        }
        //更新内容
        updateUI()
        self.superview?.needsLayout = true
        self.superview?.layout()
    }
  
    
    func updateUI() {
        guard let mainNode = mainNode else {
            return
        }
        let mainFactor = caculateNodeScaleFactor(mainNode.frameInWindow())
        mainView.snp.remakeConstraints { make in
            make.width.equalToSuperview().multipliedBy(mainFactor.width)
            make.height.equalToSuperview().multipliedBy(mainFactor.height)
            make.centerX.equalToSuperview().multipliedBy(mainFactor.centerX)
            make.centerY.equalToSuperview().multipliedBy(mainFactor.centerY)
        }
        if let targetNode = self.targetNode {
            let targertFactor = caculateNodeScaleFactor(targetNode.frameInWindow())
            targetView.snp.remakeConstraints { make in
                make.width.equalToSuperview().multipliedBy(targertFactor.width)
                make.height.equalToSuperview().multipliedBy(targertFactor.height)
                make.centerX.equalToSuperview().multipliedBy(targertFactor.centerX)
                make.centerY.equalToSuperview().multipliedBy(targertFactor.centerY)
            }
        }
        measureViews.forEach { view in
            view.removeFromSuperview()
        }
        measureViews.removeAll()
        updateMeasureUI()
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
        let yJoints = ViewMeasure.caculateXJoint(r1: frame1, r2: frame2)
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
            let rect = CGRect(x: startX, y: startY, width: endX - startX, height: 0)
            let line = addXGuideLine(rect: rect)
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
                addYGuideLine(rect: guideRect, dash: true)
            }
            //measure label
            let label = "\(Int(rect.width))"
            addXGuideLabel(label: label, relative:line)
        } else {
            
        }
    }
    
    @discardableResult
    func addXGuideLine(rect: CGRect, dash: Bool = false) -> NSView {
        let line = ViewLineView(direction: .horizonal, dash: dash)
        let frame = adhFrameFromRect(rect: rect)
        frameView.addSubview(line)
        let factor = caculateNodeScaleFactor(frame)
        line.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(factor.width)
            make.height.equalTo(1)
            make.centerX.equalToSuperview().multipliedBy(factor.centerX)
            make.centerY.equalToSuperview().multipliedBy(factor.centerY)
        }
        measureViews.append(line)
        return line
    }
    
    func addXGuideLabel(label: String, relative line: NSView) {
        let textfield = NSTextField.createLabel()
        textfield.font = NSFont.systemFont(ofSize: 10.0)
        textfield.textColor = .white
        textfield.wantsLayer = true
        textfield.layer?.backgroundColor = NSColor.red.cgColor
        textfield.cornerRadius = 4.0
        textfield.alignment = .center
        textfield.stringValue = label
        textfield.sizeToFit()
        let width = textfield.bounds.size.width + 8
        let height = textfield.bounds.size.height
        frameView.addSubview(textfield)
        textfield.snp.makeConstraints { make in
            make.top.equalTo(line).offset(8)
            make.centerX.equalTo(line)
            make.width.equalTo(width)
            make.height.equalTo(height)
        }
        measureViews.append(textfield)
    }
    
    @discardableResult
    func addYGuideLine(rect: CGRect, dash: Bool = false) -> NSView {
        let line = ViewLineView(direction: .vertical, dash: dash)
        let frame = adhFrameFromRect(rect: rect)
        frameView.addSubview(line)
        let factor = caculateNodeScaleFactor(frame)
        line.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalToSuperview().multipliedBy(factor.height)
            make.centerX.equalToSuperview().multipliedBy(factor.centerX)
            make.centerY.equalToSuperview().multipliedBy(factor.centerY)
        }
        measureViews.append(line)
        return line
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
        let centerXScale = (frame.centerX / frameWidth) * 2
        let centerYScale = (frame.centerY / frameHeight) * 2
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
    
    func createFrameView() -> NSView {
        let view = NSView()
        view.backgroundColor = .brown.withAlphaComponent(0.7)
        return view
    }
    
    func createMainView() -> NSView {
        let view = NSView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.5)
        return view
    }
    
    func createTargetView() -> NSView {
        let view = NSView()
        view.backgroundColor = .systemRed.withAlphaComponent(0.5)
        return view
    }
    
    override var intrinsicContentSize: NSSize {
        return containerSize
    }
    
}



