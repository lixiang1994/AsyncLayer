//
//  AsyncLayer.swift
//  ┌─┐      ┌───────┐ ┌───────┐
//  │ │      │ ┌─────┘ │ ┌─────┘
//  │ │      │ └─────┐ │ └─────┐
//  │ │      │ ┌─────┘ │ ┌─────┘
//  │ └─────┐│ └─────┐ │ └─────┐
//  └───────┘└───────┘ └───────┘
//
//  Created by lee on 2019/1/15.
//  Copyright © 2019年 lee. All rights reserved.
//

import UIKit

public protocol AsyncLayerDelegate {
    
    /// 显示即将开始
    ///
    /// - Parameter layer: 图层
    func display(will layer: AsyncLayer)
    
    /// 显示绘制
    ///
    /// - Parameters:
    ///   - layer: 图层
    ///   - context: 上下文
    ///   - size: 大小
    ///   - isCancelled: 是否已取消
    func display(draw layer: AsyncLayer,
               at context: CGContext,
               with size: CGSize,
               isCancelled: (() -> Bool))
    
    /// 显示已经完成
    ///
    /// - Parameters:
    ///   - layer: 图层
    ///   - finished: 是否已完成
    func display(did layer: AsyncLayer, with finished: Bool)
}

extension AsyncLayerDelegate {
    func display(will layer: AsyncLayer) { }
    func display(did layer: AsyncLayer, with finished: Bool) { }
}

public class AsyncLayer: CALayer {
    
    private static let queues: [DispatchQueue] = {
        (0 ... $0).map { _ in DispatchQueue(label: "com.lee.async.render") }
    } (max(min(ProcessInfo().activeProcessorCount, 16), 1))
    
    private static var current = 0
    private static var display: DispatchQueue {
        objc_sync_enter(self)
        current += current == Int.max ? -current : 1
        objc_sync_exit(self)
        return queues[current % queues.count]
    }
    private var atomic = 0
    
    /// 是否异步处理
    public var isAsynchronously: Bool = true
        
    public override func setNeedsDisplay() {
        cancel()
        super.setNeedsDisplay()
    }
    
    public override func display() {
        super.contents = super.contents
        display(isAsynchronously)
    }
    
    public func cancel() {
        objc_sync_enter(self)
        atomic += 1
        objc_sync_exit(self)
    }
    
    deinit {
        print("deinit:\t\(classForCoder)")
        cancel()
    }
}

extension AsyncLayer {
    
    private func display(_ async: Bool) {
        guard let delegate = delegate as? AsyncLayerDelegate else {
            return
        }
        
        delegate.display(will: self)
        
        if async {
            let size = bounds.size
            let opaque = isOpaque
            let scale = UIScreen.main.scale
            let background = (opaque && (backgroundColor != nil)) ? backgroundColor : nil
            
            let current = atomic
            let isCancelled = { return current != self.atomic }
            
            AsyncLayer.display.async { [weak self] in
                guard let self = self else { return }
                guard !isCancelled() else { return }
                
                UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
                guard let context = UIGraphicsGetCurrentContext() else { return }
                
                if opaque {
                    context.saveGState()
                    let rect = CGRect(
                        x: 0,
                        y: 0,
                        width: size.width * scale,
                        height: size.height * scale
                    )
                    if background == nil || background?.alpha != 1 {
                        context.setFillColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                        context.addRect(rect)
                        context.fillPath()
                    }
                    if let color = background {
                        context.setFillColor(color)
                        context.addRect(rect)
                        context.fillPath()
                    }
                    context.restoreGState()
                }
                
                delegate.display(draw: self, at: context, with: size, isCancelled: isCancelled)
                
                if isCancelled() {
                    UIGraphicsEndImageContext()
                    DispatchQueue.main.async {
                        delegate.display(did: self, with: false)
                    }
                    return
                }
                
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                if isCancelled() {
                    UIGraphicsEndImageContext()
                    DispatchQueue.main.async {
                        delegate.display(did: self, with: false)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    if isCancelled() {
                        delegate.display(did: self, with: false)
                        
                    } else {
                        self.contents = image?.cgImage
                        delegate.display(did: self, with: true)
                    }
                }
            }
            
        } else {
            UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, UIScreen.main.scale)
            guard let context = UIGraphicsGetCurrentContext() else { return }
            
            if isOpaque {
                var size = bounds.size
                size.width *= contentsScale
                size.height *= contentsScale
                context.saveGState()
                
                if backgroundColor == nil || backgroundColor!.alpha < 1 {
                    context.setFillColor(UIColor.white.cgColor)
                    context.addRect(CGRect(origin: .zero, size: size))
                    context.fillPath()
                }
                if let color = backgroundColor {
                    context.setFillColor(color)
                    context.addRect(CGRect(origin: .zero, size: size))
                    context.fillPath()
                }
                context.restoreGState()
            }
            
            delegate.display(draw: self, at: context, with: bounds.size) { return false }
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            contents = image?.cgImage
            delegate.display(did: self, with: true)
        }
    }
}
