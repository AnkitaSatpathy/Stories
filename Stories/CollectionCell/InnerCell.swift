//
//  InnerCell.swift
//  Stories
//
//  Created by Mahavirsinh Gohil on 19/12/18.
//  Copyright © 2018 Mahavirsinh Gohil. All rights reserved.
//

import UIKit

var storyZoomingBlock:((_ isZooming: Bool) -> ())?

class InnerCell: UICollectionViewCell {
    
    @IBOutlet weak var scrollV: UIScrollView!
    @IBOutlet weak var imgStory: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollV.maximumZoomScale = 3.0;
        scrollV.minimumZoomScale = 1.0;
        scrollV.clipsToBounds = true;
        scrollV.delegate = self
        scrollV.addSubview(imgStory)
    }

    func setImage(_ image: UIImage) {
        imgStory.image = image
        setContentMode()
    }
    
    private func setContentMode() {
        if imgStory.image!.imageOrientation == .up {
            imgStory.contentMode = .scaleAspectFit
        } else if imgStory.image!.imageOrientation == .left || imgStory.image!.imageOrientation == .right {
            imgStory.contentMode = .scaleAspectFill
        }
    }
}

extension InnerCell: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
        storyZoomingBlock?(true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgStory
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        UIView.animate(withDuration: 0.3, animations: { 
            print("scrollViewDidEndDragging")
            self.scrollV.zoomScale = 1.0
        }) { (isAnimationDone) in
            if isAnimationDone {
                storyZoomingBlock?(false)
            }
        }
    }
}
