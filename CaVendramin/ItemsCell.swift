//
//  ItemsCell.swift
//  Papers
//
//  Created by Massimo Moro on 10/11/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

class ItemsCell: UICollectionViewCell {
    
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var ImageCell: UIImageView!
    
    var item:Paper? {
        didSet{
            if let item = item  {
                ImageCell.image = UIImage(named: item.imageName)
                captionLabel.text = item.caption
            }
        }
    }
}
