//
//  ViewController.swift
//  DestinationMusic
//
//  Created by locklight on 2018/4/27.
//  Copyright © 2018年 locklight. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SearchViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search Word is:'\(searchBar.text!)'")
        
        searchBar.resignFirstResponder()
        if searchBar.text! != "HeyJude" {
            for i in 0...2 {
                let searchResult = SearchResult()
                searchResult.name = String(format: "Fake Result %d for", i)
                searchResult.artistName = searchBar.text!
                searchResults.append(searchResult)
            }
        }
        hasSearched = true
        tableView.reloadData()
    }
}

extension SearchViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        }else if searchResults.count == 0{
            return 1
        }else{
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchRusultCell"
        
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if  cell == nil {
            cell = UITableViewCell(style:.subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if searchResults.count == 0 {
            cell.textLabel!.text = "nothing not found"
            cell.detailTextLabel!.text = ""
        }else{
            let searchResult = searchResults[indexPath.row]
            cell.textLabel!.text = searchResult.name
            cell.detailTextLabel!.text = searchResult.artistName
        }
        return cell
    }
}

extension SearchViewController:UIBarPositioningDelegate{
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
