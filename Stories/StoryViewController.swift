//
//  ViewController.swift
//  Stories
//
//  Created by Ankita Satpathy on 16/10/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import UIKit

class StoryHandler {
    var images: [UIImage]
    var storyIndex: Int = 0
    static var userIndex: Int = 0
    
    init(imgs: [UIImage]) {
        images = imgs
    }
}

class StoryViewController: UIViewController {

    @IBOutlet weak var outerCollection: UICollectionView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var rowIndex:Int = 0
    var arrUser = [StoryHandler]()
    var currentStoryBar: StoryBar!
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    let imgCollection = [[UIImage(named:"pexels-photo-4525"),UIImage(named:"pexels-photo-302053"), UIImage(named:"pexels-photo-415326"),UIImage(named:"pexels-photo-452558")], [UIImage(named:"pexels-photo-4525"),UIImage(named:"pexels-photo-452558")]] as! [[UIImage]]
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelBtn.addTarget(self, action: #selector(cancelBtnTouched), for: .touchUpInside)
        setupModel()
        addGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if let cell = outerCollection.cellForItem(at: IndexPath(item: rowIndex, section: 0)) as? OuterCell {
            currentStoryBar.startAnimation()
//        }
    }

    @IBAction func cancelBtnTouched() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK:- Helper Methods
extension StoryViewController {
    
    func setupModel() {
        for collection in imgCollection {
            arrUser.append(StoryHandler(imgs: collection))
        }
        StoryHandler.userIndex = rowIndex
        outerCollection.reloadData()
        outerCollection.scrollToItem(at: IndexPath(item: StoryHandler.userIndex, section: 0),
                                     at: .centeredHorizontally, animated: false)
    }
    
    func currentStoryIndexChanged(index: Int) {
        arrUser[StoryHandler.userIndex].storyIndex = index
    }
    
    func showNextUserStory() {
        let newUserIndex = StoryHandler.userIndex + 1
        if newUserIndex < arrUser.count {
            StoryHandler.userIndex = newUserIndex
            outerCollection.reloadItems(at: [IndexPath(item: StoryHandler.userIndex, section: 0)])
            outerCollection.scrollToItem(at: IndexPath(item: StoryHandler.userIndex, section: 0),
                                         at: .centeredHorizontally, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { 
                self.currentStoryBar.startAnimation()
            }
        } else {
            cancelBtnTouched()
        }
    }
    
    func showPreviousUserStory() {
        let newIndex = StoryHandler.userIndex - 1
        if newIndex >= 0 {
            StoryHandler.userIndex = newIndex
            arrUser[StoryHandler.userIndex].storyIndex = 0
            outerCollection.reloadItems(at: [IndexPath(item: StoryHandler.userIndex, section: 0)])
            outerCollection.scrollToItem(at: IndexPath(item: StoryHandler.userIndex, section: 0),
                                         at: .centeredHorizontally, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { 
                self.currentStoryBar.startAnimation()
            }
        } else {            
            cancelBtnTouched()
        }
    }
}

// MARK:- Gestures
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
        let touchLocation: CGPoint = gesture.location(in: gesture.view)
        let maxLeftSide = ((view.bounds.maxX * 40) / 100) // Get 40% of Left side
        if touchLocation.x < maxLeftSide {
            currentStoryBar.previous()
        } else {
            currentStoryBar.next()
        }
    }
    
    @objc func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)        
        if sender.state == .began {
            currentStoryBar.pause()
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
                currentStoryBar.resume()
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0,
                                             width: self.view.frame.size.width,
                                             height: self.view.frame.size.height)
                })
            }
        }
    }
}

// MARK:- Collection View Data Source and Delegate
extension StoryViewController: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIScreen.main.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! OuterCell
        cell.weakParent = self
        cell.setStory(story: arrUser[indexPath.row])
        return cell
    }
}

// MARK:- Scroll View Delegate
extension StoryViewController {

//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        currentStoryBar.pause()
//    }
//    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        currentStoryBar.startAnimation()
//    }
}
