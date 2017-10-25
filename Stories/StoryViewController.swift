//
//  ViewController.swift
//  Stories
//
//  Created by Ankita Satpathy on 16/10/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import UIKit

class StoryViewController: UIViewController, SegmentedProgressBarDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var storyBar: StoryBar!
    //let imageView = UIImageView()
    let images = [UIImage(named:"pexels-photo-302053"), UIImage(named:"pexels-photo-415326"),UIImage(named:"pexels-photo-452558")]

                  //[UIImage(named:"nature-animal-dog-playing"), UIImage(named:"pexels-photo-257558"),UIImage(named:"pexels-photo-264778")]]
                  
    
    var rowIndex = Int()
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      self.view.backgroundColor = UIColor.white
        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFill
        //view.addSubview(imageView)
        updateImage(index: 0)
        
        
        storyBar = StoryBar(numberOfSegments: 3, duration: 5)
        storyBar.frame = CGRect(x: 15, y: 15, width: view.frame.width - 30, height: 4)
        storyBar.delegate = self
        storyBar.animatingBarColor = UIColor.white
        storyBar.nonAnimatingBarColor = UIColor.white.withAlphaComponent(0.25)
        storyBar.padding = 2
        view.addSubview(storyBar)
        
        //storyBar.startAnimation()
        let btnImage = UIImage(named: "cross.png")
        cancelBtn.setImage(btnImage!, for: .normal)
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        storyBar.startAnimation()
    }
    
    @IBAction func cancelBtnTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func segmentedProgressBarChangedIndex(index: Int) {
        updateImage(index: index)
    }
    
    private func updateImage(index: Int) {
        //imageView.image = images[rowIndex][index]
       imageView.image = images[index]
    }

}

