//
//  FPSLabel.swift
//  AsyncLayerDemo
//
//  Created by 李响 on 2019/1/16.
//  Copyright © 2019 swift. All rights reserved.
//

import UIKit

class FPSLabel: UILabel {

    private lazy var link = CADisplayLink(
        target: Weak(self),
        selector: #selector(linkAction)
    )
    private var count: Int = 0
    private var last: TimeInterval = 0
    private let size = CGSize(width: 55, height: 20)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        frame = CGRect(origin: frame.origin, size: size)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return size
    }
    
    private func setup() {
        layer.cornerRadius = 5
        clipsToBounds = true
        textAlignment = .center
        isUserInteractionEnabled = false
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2935185185)
        
        font = .systemFont(ofSize: 14)
        
        link.add(to: .main, forMode: .common)
    }
    
    deinit {
        print("deinit:\t\(classForCoder)")
        link.invalidate()
    }
}

extension FPSLabel {
    
    @objc private func linkAction(_ sender: CADisplayLink) {
        guard last > 0 else {
            last = sender.timestamp
            return
        }
        
        count += 1
        let delta = sender.timestamp - last
        
        guard delta >= 1 else { return }
        
        last = sender.timestamp
        let fps = Double(count) / delta
        count = 0
        
        let progress = fps / 60
        let string = NSMutableAttributedString(string: "\(Int(fps.rounded()))FPS")
        let color = UIColor(
            hue: CGFloat(0.27 * (progress - 0.2)),
            saturation: 1,
            brightness: 0.9,
            alpha: 1
        )
        string.addAttributes(
            [.foregroundColor: color,
             .font: UIFont(name: "Menlo", size: 14) ?? .systemFont(ofSize: 14)],
            range: NSRange(location: 0, length: string.length - 3)
        )
        string.addAttributes(
            [.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
             .font: UIFont(name: "Menlo", size: 14) ?? .systemFont(ofSize: 14)],
            range: NSRange(location: string.length - 3, length: 3)
        )
        attributedText = string
    }
}

class Weak: NSObject {
    
    private weak var target: AnyObject?
    
    init(_ target: AnyObject) {
        self.target = target
        super.init()
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        return target?.responds(to: aSelector) ?? super.responds(to: aSelector)
    }
    
    override func method(for aSelector: Selector!) -> IMP! {
        return target?.method(for: aSelector) ?? super.method(for: aSelector)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        return target?.isEqual(object) ?? super.isEqual(object)
    }
    
    override func isKind(of aClass: AnyClass) -> Bool {
        return target?.isKind(of: aClass) ?? super.isKind(of: aClass)
    }
    
    override var superclass: AnyClass? {
        return target?.superclass
    }
    
    override func isProxy() -> Bool {
        return target?.isProxy() ?? super.isProxy()
    }
    
    override var hash: Int {
        return target?.hash ?? super.hash
    }
    
    override var description: String {
        return target?.description ?? super.description
    }
    
    override var debugDescription: String {
        return target?.debugDescription ?? super.debugDescription
    }
    
    deinit { print("deinit:\t\(classForCoder)") }
}
