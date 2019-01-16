//
//  TableViewCell.swift
//  AsyncLayerDemo
//
//  Created by 李响 on 2019/1/16.
//  Copyright © 2019 swift. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    private let view = AsyncTextView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.addSubview(view)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        view.frame = contentView.bounds
    }
    
    func set(text: String) {
        view.text = text
    }
}
