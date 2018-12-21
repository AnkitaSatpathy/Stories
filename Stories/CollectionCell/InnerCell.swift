//
//  InnerCell.swift
//  Stories
//
//  Created by Mahavirsinh Gohil on 19/12/18.
//  Copyright © 2018 Ankita Satpathy. All rights reserved.
//

import UIKit

class InnerCell: UICollectionViewCell {
    @IBOutlet weak var imgStory: UIImageView!
    
    func setImage(_ image: UIImage) {
        imgStory.image = image
        if imgStory.image!.imageOrientation == .up {
            imgStory.contentMode = .scaleAspectFit
        } else if imgStory.image!.imageOrientation == .left || imgStory.image!.imageOrientation == .right {
            imgStory.contentMode = .scaleAspectFill
        }
    }
}
