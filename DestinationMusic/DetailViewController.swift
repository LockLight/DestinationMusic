//
//  DetailViewController.swift
//  DestinationMusic
//
//  Created by locklight on 2018/5/7.
//  Copyright © 2018年 locklight. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    var downloadTask:URLSessionDownloadTask?
    
    var searchResult:SearchResult!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.tintColor = UIColor(red: 20/255, green: 160/255,
                                 blue: 160/255, alpha: 1)
        popupView.layer.cornerRadius = 10
        
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(close(_:)))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        if (searchResult != nil) {
            updateUI()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    deinit {
        downloadTask?.cancel()
    }
    
    func updateUI(){
        nameLabel.text = searchResult.name
        artistNameLabel.text = searchResult.artistName.isEmpty == false ? searchResult.artistName : "Unknown"
        kindLabel.text = searchResult.kind
        genreLabel.text = searchResult.genre
        
        let numFomatter = NumberFormatter()
        numFomatter.numberStyle = .currency
        numFomatter.currencyCode = searchResult.currency
        
        let priceText:String
        if searchResult.price == 0{
            priceText = "Free"
        }else if let text = numFomatter.string(from: searchResult.price as NSNumber){
            priceText = text
        }else{
            priceText = ""
        }
        priceButton.setTitle(priceText, for: .normal)
        
        if let largeURL = URL(string: searchResult.imageLarge){
            downloadTask = artworkImageView.loadImage(url: largeURL)
        }
    }

    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openInStore(_ sender: UIButton) {
        if let url = URL(string: searchResult.storeURL){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension DetailViewController:UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension DetailViewController:UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view == self.view)
    }
}


