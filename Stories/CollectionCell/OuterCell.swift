//
//  OuterCellCollectionViewCell.swift
//  Stories
//
//  Created by Mahavirsinh Gohil on 19/12/18.
//  Copyright © 2018 Mahavirsinh Gohil. All rights reserved.
//

import UIKit

class OuterCell: UICollectionViewCell {
    
    @IBOutlet weak var innerCollection: UICollectionView!
    
    weak var weakParent: StoryViewController?
    var story: StoryHandler!
    var storyBar: StoryBar!
    
    func setStory(story: StoryHandler) {
        self.story = story
        self.contentView.layoutIfNeeded()
        addStoryBar()
        innerCollection.reloadData()
        innerCollection.scrollToItem(at: IndexPath(item: story.storyIndex, section: 0),
                                     at: .centeredHorizontally, animated: false)
    }

    private func addStoryBar() {
        if let _ = storyBar {
            storyBar.removeFromSuperview()
            storyBar = nil
        }
        storyBar = StoryBar(numberOfSegments: story.images.count)
        storyBar.frame = CGRect(x: 15, y: 15, width: weakParent!.view.frame.width - 30, height: 4)
        storyBar.delegate = self
        storyBar.animatingBarColor = UIColor.white
        storyBar.nonAnimatingBarColor = UIColor.white.withAlphaComponent(0.25)
        storyBar.padding = 2
        storyBar.resetSegmentsTill(index: story.storyIndex)
        self.contentView.addSubview(storyBar)
    }
}

// MARK:- Segmented ProgressBar Delegate
extension OuterCell: SegmentedProgressBarDelegate {

    func segmentedProgressBarChangedIndex(index: Int) {
        weakParent?.currentStoryIndexChanged(index: index)
        innerCollection.scrollToItem(at: IndexPath(item: index, section: 0),
                                     at: .centeredHorizontally, animated: false)
    }
    
    func segmentedProgressBarReachEnd() {
        weakParent?.showNextUserStory()
    }
    
    func segmentedProgressBarReachPrevious() {
        weakParent?.showPreviousUserStory()
    }
}

// MARK:- Segmented ProgressBar Delegate
extension OuterCell: ImageZoomDelegate {

    func imageZoomStart() {
        storyBar.pause()
    }
    
    func imageZoomEnd() {
        storyBar.resume()
    }
}

// MARK:- Collection View Data Source and Delegate
extension OuterCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return story.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIScreen.main.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storyCell", for: indexPath) as! InnerCell
        cell.setImage(story.images[indexPath.row])
        cell.delegate = self
        return cell
    }
}
