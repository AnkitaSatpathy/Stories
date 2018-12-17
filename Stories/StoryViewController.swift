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
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        self.view.addGestureRecognizer(tapGest)
        
        let longPressGest = UILongPressGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        longPressGest.minimumPressDuration = 0.2
        self.view.addGestureRecognizer(longPressGest)
        
        tapGest.require(toFail: longPressGest)
    }
    
    @objc func handlePan(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            storyBar.pauseLayer()
        } else if gesture.state == .ended {
            storyBar.resumeLayer()
        }
    }

    @objc func handleTap(gesture: UITapGestureRecognizer) {
        // Get 40% of Left side
        let maxLeftSide = ((view.bounds.maxX * 40) / 100)
        let touchLocation: CGPoint = gesture.location(in: gesture.view)
        if touchLocation.x < maxLeftSide {
            storyBar.previous()
        } else {
            storyBar.next()
        }
    }
}
