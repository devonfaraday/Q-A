//
//  TutorialDataController.swift
//  Q&A
//
//  Created by Demick McMullin on 4/24/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class TutorialDataController: NSObject, UIPageViewControllerDataSource {
    
    static let shared = TutorialDataController()
    
    var pageData: [UIImage] = []
 
    override init() {
        super.init()
        pageData = [#imageLiteral(resourceName: "TopicView"), #imageLiteral(resourceName: "UserView"), #imageLiteral(resourceName: "QuestionView"), #imageLiteral(resourceName: "OwnerView"), #imageLiteral(resourceName: "ReadyCheck")]
        
    }
    
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> TutorialDataViewController? {
        // Return the data view controller for the given index.
        if (self.pageData.count == 0) || (index >= self.pageData.count) {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewController(withIdentifier: "TutorialDataViewController") as? TutorialDataViewController
        dataViewController?.tutorialImage = self.pageData[index]
        return dataViewController
    }
    
    func indexOfViewController(_ viewController: TutorialDataViewController) -> Int {
        // Return the index of the given data view controller.
       guard let tutorialImage = viewController.tutorialImage else {return 0}
        return pageData.index(of: tutorialImage) ?? NSNotFound
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! TutorialDataViewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! TutorialDataViewController)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == self.pageData.count {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
}
