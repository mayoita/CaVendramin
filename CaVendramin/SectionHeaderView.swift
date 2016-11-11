//
//  SectionHeaderView.swift
//  Papers
//
//  Created by Massimo Moro on 10/11/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
        
    @IBOutlet weak var titleLabel: UILabel!
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
}
