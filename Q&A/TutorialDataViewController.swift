//
//  TutorialDataViewController.swift
//  Q&A
//
//  Created by Demick McMullin on 4/24/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class TutorialDataViewController: UIViewController {

    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var page: UIPageControl!
    @IBOutlet weak var doneButton: UIButton!
    
   
    var tutorialImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton.layer.cornerRadius = 5
        self.doneButton.layer.borderWidth = 1
        self.doneButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let index = TutorialDataController.shared.indexOfViewController(self)
        guard let tutorialImage = tutorialImage else {return}
        imageOutlet.image = tutorialImage
        page.isEnabled = false
        page.currentPageIndicatorTintColor = UIColor.blue
        page.numberOfPages = TutorialDataController.shared.pageData.count
        page.currentPage = index
        page.isHidden = false
    }


}
