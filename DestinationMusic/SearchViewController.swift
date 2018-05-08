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
    @IBOutlet weak var SegmentControl: UISegmentedControl!
    
    var landScapeVC:LandscapeViewController?
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    var dataTask:URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.becomeFirstResponder()
        
        tableView.contentInset = UIEdgeInsetsMake(108, 0, 0, 0);
        tableView.rowHeight = 80
        
        tableView.register(UINib(nibName:TableViewIndentifier.SearchResultCell, bundle: nil), forCellReuseIdentifier: TableViewIndentifier.SearchResultCell)
        tableView.register(UINib(nibName:TableViewIndentifier.NothingResultCell, bundle: nil), forCellReuseIdentifier: TableViewIndentifier.NothingResultCell)
        tableView.register(UINib(nibName: TableViewIndentifier.LoadingCell, bundle: nil), forCellReuseIdentifier: TableViewIndentifier.LoadingCell)
    }

    //MARK: - rotation
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super .willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
            case .compact:
                showLandScape(with: coordinator)
            case .regular,.unspecified:
                hideLandScape(with: coordinator)
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail"{
            let detailViewController = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath
            detailViewController.searchResult = searchResults[indexPath.row]
        }
    }
    
    //MARK: - private methods
    func showLandScape(with coordinator:UIViewControllerTransitionCoordinator){
        // 1
        guard landScapeVC == nil else {return}
        // 2
        landScapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        // 3
        if let VC = landScapeVC {
            VC.view.frame = view.bounds
            VC.view.alpha = 0
            view.addSubview(VC.view)
            addChildViewController(VC)
            
            coordinator.animate(alongsideTransition: { (_) in
                VC.view.alpha = 1
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }) { (_) in
                VC.didMove(toParentViewController: self)
            }
        }
    }
    
    func hideLandScape(with coordinator:UIViewControllerTransitionCoordinator){
        if let VC = landScapeVC{
            VC.willMove(toParentViewController: nil)
            
            coordinator.animate(alongsideTransition: { (_) in
                VC.view.alpha = 0
                self.searchBar.becomeFirstResponder()
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }) { (_) in
                VC.view.removeFromSuperview()
                VC.removeFromParentViewController()
                self.landScapeVC = nil
            }
        }
    }
    
    func iTunesURL(searchText:String,category:Int) -> URL {
        let kind:String
        switch category {
            case 1:     kind = "musicTrack"
            case 2:     kind = "software"
            case 3:     kind = "ebook"
            default:    kind = ""
        }
        
        let encodeText = searchText.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)!
        let url = URL(string: String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@", encodeText,kind))
        return url!
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
    
    func performSearch(){
        if !searchBar.text!.isEmpty{
            searchBar.resignFirstResponder()
            hasSearched = true
            isLoading = true
            dataTask?.cancel()
            tableView.reloadData()
            searchResults = []
            
            let url = self.iTunesURL(searchText: searchBar.text!,category: SegmentControl.selectedSegmentIndex)
            print("URL:'\(url)'")
            
            let session = URLSession.shared
            
            dataTask = session.dataTask(with: url) { (data, response, error) in
                if let error = error as NSError? , error.code == -999{
                    print("Failure\(error)")
                    return
                }else if let httpResponse = response as? HTTPURLResponse,httpResponse.statusCode == 200{
                    print("Success\(data!)")
                    
                    if let data = data{
                        self.searchResults = self.parse(data: data)
                        self.searchResults.sort(by: <)
                        
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                    }
                    return
                }else{
                    print("Success\(response!)")
                }
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetWorkError()
                }
            }
            dataTask?.resume()
        }
    }
    
    //MARK: - Event Response
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
}


extension SearchViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
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
            cell.configure(for: searchResult)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender:indexPath)
    }
}

extension SearchViewController:UIBarPositioningDelegate{
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
