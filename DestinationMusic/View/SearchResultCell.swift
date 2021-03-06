//
//  SearchResultCell.swift
//  DestinationMusic
//
//  Created by locklight on 2018/4/28.
//  Copyright © 2018年 locklight. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var artImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    private var downloadTask:URLSessionDownloadTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255,
                                               green: 160/255,
                                               blue: 160/255,
                                               alpha: 0.5)
        selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(for result:SearchResult){
        nameLabel.text = result.name
        
        if result.artistName.isEmpty{
            artistNameLabel.text = "Unknown"
        }else{
            artistNameLabel.text = String(format: "%@ (%@)",result.artistName,result.type)
        }
        
        artImgView.image = UIImage(named: "Placeholder")
        if let smallURL = URL(string: result.imageSmall){
            downloadTask = artImgView.loadImage(url: smallURL)
        }
    }
}
