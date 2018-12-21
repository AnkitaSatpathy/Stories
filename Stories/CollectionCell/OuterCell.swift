//
//  OuterCellCollectionViewCell.swift
//  Stories
//
//  Created by Mahavirsinh Gohil on 19/12/18.
//  Copyright © 2018 Ankita Satpathy. All rights reserved.
//

import UIKit

class OuterCell: UICollectionViewCell {
    
    @IBOutlet weak var innerCollection: UICollectionView!
    
    weak var weakParent: StoryViewController?
    var story: StoryHandler!
    var storyBar: StoryBar!
    
    func setStory(story: StoryHandler) {
        self.story = story
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
        storyBar = StoryBar(numberOfSegments: story.images.count, duration: 5)
        storyBar.frame = CGRect(x: 15, y: 15, width: weakParent!.view.frame.width - 30, height: 4)
        storyBar.delegate = self
        storyBar.animatingBarColor = UIColor.white
        storyBar.nonAnimatingBarColor = UIColor.white.withAlphaComponent(0.25)
        storyBar.padding = 2
        self.contentView.addSubview(storyBar)
        weakParent?.currentStoryBar = storyBar
        storyBar.resetSegmentsTill(index: story.storyIndex)
    }
}

// MARK:- Helper Methods
extension OuterCell {
    
    func showImageWithIndex(_ index: Int) {
        innerCollection.scrollToItem(at: IndexPath(item: index, section: 0),
                                     at: .centeredHorizontally, animated: false)
    }
}

// MARK:- Segmented ProgressBar Delegate
extension OuterCell: SegmentedProgressBarDelegate {

    func segmentedProgressBarChangedIndex(index: Int) {
        weakParent?.currentStoryIndexChanged(index: index)
        showImageWithIndex(index)
    }
    
    func segmentedProgressBarReachEnd() {
        storyBar.resetSegmentsTill(index: story.storyIndex)
        weakParent?.showNextUserStory()
    }
    
    func segmentedProgressBarReachPrevious() {
        storyBar.resetSegmentsTill(index: story.storyIndex)
        weakParent?.showPreviousUserStory()
    }
}

// MARK:- Collection View Data Source and Delegate
extension OuterCell: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return story.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storyCell", for: indexPath) as! InnerCell
        cell.setImage(story.images[indexPath.row])
        return cell
    }
}
