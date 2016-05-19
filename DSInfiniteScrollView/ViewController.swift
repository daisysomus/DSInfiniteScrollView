//
//  ViewController.swift
//  DSInfiniteScrollView
//
//  Created by liaojinhua on 16/5/19.
//  Copyright © 2016年 Daisy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var infiniteScrollView: DSInfiniteScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        infiniteScrollView.delegate = self
        infiniteScrollView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController:DSInfiniteScrollViewDelegate {
    
    func numberOfViews(scrollView: DSInfiniteScrollView) -> Int {
        return 3
    }
    
    func scrollingViewClassName(scrollView: DSInfiniteScrollView) -> String {
        return String(UIImageView)
    }
    
    func scrollView(scrollView: DSInfiniteScrollView, configView: UIView, atIndex index: Int) {
        let imageView = configView as! UIImageView
        
        
        let imageName = "image" + "\(index%3 + 1)"
        imageView.image = UIImage(named: imageName)
    }
}

