//
//  ViewController.swift
//  Stories
//
//  Created by Ankita Satpathy on 16/10/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import UIKit

class StoryViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var storyBar: StoryBar!
    //let imageView = UIImageView()
    let images = [UIImage(named:"pexels-photo-302053"), UIImage(named:"pexels-photo-415326"),UIImage(named:"pexels-photo-452558")]
    
    var rowIndex: Int? = nil
    @IBOutlet weak var cancelBtn: UIButton!
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFill
        //view.addSubview(imageView)
        updateImage(index: 0)

        addStoryBar()
        addGesture()
        
        //storyBar.startAnimation()
        let btnImage = UIImage(named: "cross.png")
        cancelBtn.setImage(btnImage!, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnTouched), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        storyBar.startAnimation()
    }
    
    func addStoryBar() {
        storyBar = StoryBar(numberOfSegments: images.count, duration: 5)
        storyBar.frame = CGRect(x: 15, y: 15, width: view.frame.width - 30, height: 4)
        storyBar.delegate = self
        storyBar.animatingBarColor = UIColor.white
        storyBar.nonAnimatingBarColor = UIColor.white.withAlphaComponent(0.25)
        storyBar.padding = 2
        view.addSubview(storyBar)
    }
    
    @IBAction func cancelBtnTouched() {
        self.dismiss(animated: true, completion: nil)
    }

    private func updateImage(index: Int) {
        imageView.image = images[index]
    }
}

// MARK: - Segment Delegates
extension StoryViewController: SegmentedProgressBarDelegate {
    
    func segmentedProgressBarChangedIndex(index: Int) {
        updateImage(index: index)
    }
    
    func segmentedProgressBarReachEnd() {
        cancelBtnTouched()
    }
    
    func segmentedProgressBarReachPrevious() {
        cancelBtnTouched()
    }
}

// MARK: - Gestures
extension StoryViewController {

    func addGesture() {
        // for previous and next navigation
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGest)
        
        // To pause and resume animation
        let longPressGest = UILongPressGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler))
        longPressGest.minimumPressDuration = 0.2
        self.view.addGestureRecognizer(longPressGest)
        
        /*
         swipe down to dismiss
         NOTE: Self's presentation style should be "Over Current Context"
         */
        let panGest = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler))
        self.view.addGestureRecognizer(panGest)
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        // Get 40% of Left side
        let maxLeftSide = ((view.bounds.maxX * 40) / 100)
        let touchLocation: CGPoint = gesture.location(in: gesture.view)
        if touchLocation.x < maxLeftSide {
            storyBar.previous()
        } else {
            storyBar.next()
        }
    }
    
    @objc func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        if sender.state == .began {
            storyBar.pause()
            initialTouchPoint = touchPoint
        } else if sender.state == .changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.view.frame = CGRect(x: 0, y: max(0, touchPoint.y - initialTouchPoint.y),
                                         width: self.view.frame.size.width,
                                         height: self.view.frame.size.height)
            }
        } else if sender.state == .ended || sender.state == .cancelled {
            if touchPoint.y - initialTouchPoint.y > 200 {
                dismiss(animated: true, completion: nil)
            } else {
                storyBar.resume()
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0,
                                             width: self.view.frame.size.width,
                                             height: self.view.frame.size.height)
                })
            }
        }
    }
}
