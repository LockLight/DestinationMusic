//
//  LandscapeViewController.swift
//  DestinationMusic
//
//  Created by locklight on 2018/5/8.
//  Copyright © 2018年 locklight. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var search:Search!
    private var firstTime = true
    private var downLoads = [URLSessionDownloadTask]()
    
    deinit {
        for task in downLoads{
            task.cancel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
        pageControl.removeConstraints(view.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        scrollView.contentInsetAdjustmentBehavior = .always

        if firstTime{
            firstTime = false
            
            switch search.state{
            case .loading,.noResults,.notSearchYet: break
            case .results(let list): titleButtons(list)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        pageControl.frame = CGRect(x: 0,
                                   y: view.frame.size.height - pageControl.frame.size.height,
                                   width: view.frame.size.width,
                                   height: pageControl.frame.size.height)
    }
    //MARK: - Event response
    @IBAction func pageChanged(_ sender: UIPageControl) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            self.scrollView.contentOffset =
                CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
        }, completion: nil)
    }
    
    //MARK: - Private Methods
    private func downloadImage(for searchResult:SearchResult,
                               andPlaceOn button:UIButton){
        if let url = URL(string:searchResult.imageLarge){
            let task = URLSession.shared.downloadTask(with: url) {
                [weak button] (url, response, error) in
                
                if error == nil,let url = url,
                    let data = try?Data(contentsOf: url),
                    let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        if let btn = button{
                            btn.setImage(image, for:.normal)
                        }
                    }
                }
            }
            task.resume()
            downLoads.append(task)
        }
    }
    
    
    private func titleButtons(_ searchResults:[SearchResult]){
        // calculate the grid layout
        var columnsPerPage = 5
        var rowPerPage = 3
        var itemHeight:CGFloat = 96
        var itemWidth:CGFloat = 88
        var marginX:CGFloat = 0
        var marginY:CGFloat = 20
        
        let viewWidth = scrollView.bounds.size.width
        
        switch viewWidth {
        case 568:
            columnsPerPage = 6
            itemHeight = 94
            marginX = 2
        case 667:
            columnsPerPage = 7
            itemHeight = 95
            itemWidth = 98
            marginX = 1
            marginY = 29
        case 736:
            columnsPerPage = 8
            rowPerPage = 4
            itemWidth = 92
        default:
            break
        }
        
        //button size
        let buttonWidth :CGFloat = 82
        let buttonHeight:CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth)/2
        let paddingVert = (itemHeight - buttonHeight)/2
        
        //Add button
        var row = 0
        var column = 0
        var x = marginX
        
        for (_,result) in searchResults.enumerated() {
            // 1
            let button = UIButton(type:.custom)
//            button.setBackgroundImage(#imageLiteral(resourceName: "LandscapeButton"), for: .normal)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
            downloadImage(for: result, andPlaceOn: button)
        
            // 2
            button.frame = CGRect(x: x+paddingHorz,
                                  y: marginY + CGFloat(row) * itemHeight + paddingVert,
                                  width: buttonWidth,
                                  height: buttonHeight)
            
            // 3
            scrollView.addSubview(button)
            
            // 4
            row += 1
            if row == rowPerPage{
                row = 0; x += itemWidth; column += 1
                
                if column == columnsPerPage{
                    column = 0; x += marginX * 2
                }
            }
        }
        
        //set scrollview contentsize
        let buttonsPerPage = columnsPerPage * rowPerPage
        let numPages =  (1 + (searchResults.count - 1)) / buttonsPerPage
        scrollView.contentSize = CGSize(width: CGFloat(numPages) * viewWidth,
                                        height:0)
        
        //set pagecontrol
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
    }
}

extension LandscapeViewController:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width / 2) / width)
        pageControl.currentPage = page
    }
}
