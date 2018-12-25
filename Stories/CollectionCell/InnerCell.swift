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
    
    private var isImageDragged:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollV.maximumZoomScale = 3.0;
        scrollV.minimumZoomScale = 1.0;
        scrollV.clipsToBounds = true;
        scrollV.delegate = self
        scrollV.addSubview(imgStory)
        addGestures()
    }
}

// MARK:- Helper Methods
extension InnerCell {
    
    func setImage(_ image: UIImage) {
        imgStory.image = image
        isImageDragged = false
        setContentMode()
    }
    
    private func setContentMode() {
        if imgStory.image!.imageOrientation == .up {
            imgStory.contentMode = .scaleAspectFit
        } else if imgStory.image!.imageOrientation == .left || imgStory.image!.imageOrientation == .right {
            imgStory.contentMode = .scaleAspectFill
        }
    }

    private func resetImage() {
        UIView.animate(withDuration: 0.3, animations: { 
            self.scrollV.zoomScale = 1.0
        }) { (isAnimationDone) in
            if isAnimationDone {
                storyZoomingBlock?(false)
                self.isImageDragged = false
            }
        }
    }
}

// MARK:- Gestures
extension InnerCell: UIGestureRecognizerDelegate {
    
    private func addGestures() {
        let longPressGest = UILongPressGestureRecognizer(target: self,
                                                         action: #selector(longPressGestureHandler))
        longPressGest.minimumPressDuration = 0.2
        self.contentView.addGestureRecognizer(longPressGest)
        
        // Disable Default Pinch Gesture 
        for gesture in scrollV.gestureRecognizers! {
            if gesture is UIPinchGestureRecognizer {
                gesture.isEnabled = false
            }
        }
        
        // Adding our own Pinch Gesture
        let pinchGest = UIPinchGestureRecognizer(target: self, action: #selector(viewForZooming(in:)))
        pinchGest.delegate = self
        scrollV.addGestureRecognizer(pinchGest)
    }
    
    @objc private func longPressGestureHandler(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            storyZoomingBlock?(true)
        } else if sender.state == .ended || sender.state == .cancelled {
            storyZoomingBlock?(false)
        }   
    }
}

// MARK:- Scroll View Data Source and Delegate
extension InnerCell: UIScrollViewDelegate {
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        storyZoomingBlock?(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isImageDragged = true
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgStory
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if !isImageDragged {
            resetImage()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        resetImage()
    }
}
