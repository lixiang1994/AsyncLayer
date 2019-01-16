//
//  Transaction.swift
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

import Foundation

enum Transaction {}

extension Transaction {
    
    /// 提交事务
    ///
    /// - Parameters:
    ///   - target: 目标
    ///   - selector: 方法
    static func commit(_ target: AnyObject, with selector: Selector) {
        let item = Item(target, with: selector)
        Transaction.setup
        waits.insert(item)
    }
}

extension Transaction {
    
    private static var waits: Set<Item> = []
    private static let setup: Void = {
        let runloop = CFRunLoopGetCurrent()
        let observer = CFRunLoopObserverCreate(
            kCFAllocatorDefault,
            CFRunLoopActivity.beforeWaiting.rawValue | CFRunLoopActivity.exit.rawValue,
            true,       // repeat
            0xFFFFFF,   // after CATransaction(2000000)
            callback,
            nil
        )
        CFRunLoopAddObserver(runloop, observer, .commonModes)
    } ()
    private static let callback: CFRunLoopObserverCallBack = { _,_,_ in
        waits.forEach { _ = $0.target.perform($0.selector) }
        waits = []
    }
}

extension Transaction {
    
    private struct Item: Hashable {
        
        let target: AnyObject
        let selector: Selector
        
        init(_ target: AnyObject, with selector: Selector) {
            self.target = target
            self.selector = selector
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(target.hashValue)
            hasher.combine(selector)
        }
        
        static func == (lhs: Transaction.Item, rhs: Transaction.Item) -> Bool {
            return lhs.target.hashValue == rhs.target.hashValue
                && lhs.selector == rhs.selector
        }
    }
}
