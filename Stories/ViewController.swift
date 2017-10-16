//
//  ViewController.swift
//  Stories
//
//  Created by Ankita Satpathy on 16/10/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SegmentedProgressBarDelegate {

    var storyBar: StoryBar!
    let imageView = UIImageView()
    let images = [UIImage(named:"pexels-photo-302053"), UIImage(named:"pexels-photo-415326"),UIImage(named:"pexels-photo-452558")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
      self.view.backgroundColor = UIColor.white
        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        updateImage(index: 0)
        
        
        storyBar = StoryBar(numberOfSegments: 3, duration: 5)
        storyBar.frame = CGRect(x: 15, y: 15, width: view.frame.width - 30, height: 4)
        storyBar.delegate = self
        storyBar.topColor = UIColor.white
        storyBar.bottomColor = UIColor.white.withAlphaComponent(0.25)
        storyBar.padding = 2
        view.addSubview(storyBar)
        
        storyBar.startAnimation()
    }

    
    func segmentedProgressBarChangedIndex(index: Int) {
        updateImage(index: index)
    }
    
    private func updateImage(index: Int) {
        imageView.image = images[index]
    }

}

