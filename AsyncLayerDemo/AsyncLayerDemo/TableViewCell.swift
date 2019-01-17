//
//  TableViewCell.swift
//  AsyncLayerDemo
//
//  Created by 李响 on 2019/1/16.
//  Copyright © 2019 swift. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    private let textView = AsyncTextView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.font = .systemFont(ofSize: 11)
        textView.isOpaque = false
        textView.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        textView.layer.shadowOffset = .zero
        textView.layer.shadowRadius = 1
        textView.layer.shadowOpacity = 0.1
        contentView.addSubview(textView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textView.frame = contentView.bounds
    }
    
    func set(async: Bool) {
        textView.isAsynchronously = async
    }
    
    func set(text: String) {
        textView.text = text
    }
}
