//
//  ViewController.swift
//  DestinationMusic
//
//  Created by locklight on 2018/4/27.
//  Copyright © 2018年 locklight. All rights reserved.
//

import UIKit

struct TableViewIndentifier {
    static let SearchResultCell = "SearchResultCell"
    static let NothingResultCell = "NothingResultCell"
    static let LoadingCell = "LoadingCell"
}

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.becomeFirstResponder()
        
        tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        tableView.rowHeight = 80
        
        tableView.register(UINib(nibName:TableViewIndentifier.SearchResultCell, bundle: nil), forCellReuseIdentifier: TableViewIndentifier.SearchResultCell)
        tableView.register(UINib(nibName:TableViewIndentifier.NothingResultCell, bundle: nil), forCellReuseIdentifier: TableViewIndentifier.NothingResultCell)
        tableView.register(UINib(nibName: TableViewIndentifier.LoadingCell, bundle: nil), forCellReuseIdentifier: TableViewIndentifier.LoadingCell)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - private methods
    func iTunesURL(searchText:String) -> URL {
        let encodeText = searchText.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)!
        let url = URL(string: String(format: "https://itunes.apple.com/search?term=%@&limit=200", encodeText))
        return url!
    }
    
    func performStoreRequest(with url:URL) -> Data? {
        do {
            return try Data(contentsOf: url)
        } catch {
            print("Networking Error:\(error.localizedDescription)")
            showNetWorkError()
            return nil
        }
    }
    
    func parse(data:Data) ->[SearchResult]{
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        } catch  {
            print("JSON error:'\(error)'")
            return []
        }
    }
    
    //MARK: - public Methods
    func showNetWorkError(){
        let alert = UIAlertController(title: "网络错误", message: "There was an error accessing the iTunes Store.Please try again", preferredStyle: .alert);
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated:true, completion: nil)
    }
}


extension SearchViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty{
            searchBar.resignFirstResponder()
            hasSearched = true
            isLoading = true
            tableView.reloadData()
            searchResults = []
            
            let url = self.iTunesURL(searchText: searchBar.text!)
            print("URL:'\(url)'")
            
            let queue = DispatchQueue.global()
            queue.async {
                if let data = self.performStoreRequest(with: url){
                    self.searchResults = self.parse(data: data)
                    //way1 闭包
                    //searchResults.sort { (result1, result2) -> Bool in
                    //   return result1.name.localizedStandardCompare(result2.name) == .orderedAscending
                    //}
                    //way2 尾随闭包
                    //return searchResults.sort{ $0.name.localizedStandardCompare($1.name) == .orderedAscending }
                    //way3 操作符重载 operator overloading.
                    self.searchResults.sort(by: <)
                    //                searchResults.sort{$0 < $1}
                }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.tableView.reloadData()
                }
            }

        }
    }
}

extension SearchViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        }else if !hasSearched {
            return 0
        }else if searchResults.count == 0{
            return 1
        }else{
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewIndentifier.LoadingCell, for: indexPath) as! LoadingCell
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }else if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableViewIndentifier.NothingResultCell, for: indexPath) as! NothingResultCell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewIndentifier.SearchResultCell, for: indexPath)
                as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            if searchResult.artistName.isEmpty{
                cell.artistNameLabel.text = "Unkown"
            }else{
                cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName,searchResult.type)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading{
            return nil
        }else{
            return indexPath
        }
    }
}

extension SearchViewController:UIBarPositioningDelegate{
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
