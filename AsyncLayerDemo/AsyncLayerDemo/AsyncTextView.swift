//
//  AsyncTextView.swift
//  AsyncLayerDemo
//
//  Created by 李响 on 2019/1/16.
//  Copyright © 2019 swift. All rights reserved.
//

import UIKit

class AsyncTextView: UIView {
    
    var font: UIFont = .systemFont(ofSize: 16) {
        didSet { updatedTransaction() }
    }
    
    var text: String = "" {
        didSet { updatedTransaction() }
    }
    
    /// 是否异步处理
    var isAsynchronously: Bool {
        set { (layer as? AsyncLayer)?.isAsynchronously = newValue }
        get { return (layer as? AsyncLayer)?.isAsynchronously ?? false }
    }
    
    override class var layerClass: AnyClass {
        return AsyncLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updatedTransaction()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updatedTransaction()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatedTransaction()
    }
    
    private func updatedTransaction() {
        Transaction.commit(self, with: #selector(contentsNeedUpdated))
    }
    
    @objc private func contentsNeedUpdated() {
        layer.setNeedsDisplay()
    }
}

extension AsyncTextView: AsyncLayerDelegate {
    
    func display(draw layer: AsyncLayer, at context: CGContext, with size: CGSize, isCancelled: (() -> Bool)) {
        
        // 将坐标系上下翻转
        context.textMatrix = .identity
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)
        
        let textPath = CGMutablePath()
        textPath.addRect(CGRect(origin: .zero, size: size))
        context.addPath(textPath)
        
        // 根据framesetter和绘图区域创建CTFrame
        
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        
        let attrString = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .kern: -0.5,
                .foregroundColor: UIColor.brown,
                .paragraphStyle: style
            ]
        )
        
        let framesetter = CTFramesetterCreateWithAttributedString(attrString)
        let frame = CTFramesetterCreateFrame(
            framesetter, CFRangeMake(0, attrString.length),
            textPath,
            nil
        )
        // 使用CTFrameDraw进行绘制
        CTFrameDraw(frame, context)
    }
}
