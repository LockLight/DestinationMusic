    //
//  ViewController.swift
//  DestinationMusic
//
//  Created by locklight on 2018/4/27.
//  Copyright © 2018年 locklight. All rights reserved.
//

import UIKit

private struct TableViewIndentifier {
    static let SearchResultCell = "SearchResultCell"
    static let NothingResultCell = "NothingResultCell"
    static let LoadingCell = "LoadingCell"
}

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var SegmentControl: UISegmentedControl!
    
    var landScapeVC:LandscapeViewController?
    private let search = Search()
    
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
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                let indexPath = sender as! IndexPath
                detailViewController.searchResult = list[indexPath.row]
            }
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
            VC.search = search
            
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
            }) { (_) in
                VC.view.removeFromSuperview()
                VC.removeFromParentViewController()
                self.landScapeVC = nil
            }
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
        if let category = Search.Category(rawValue: SegmentControl.selectedSegmentIndex){
            search.performSearch(for: searchBar.text!, category: category, completion: {
                success in
                if !success{
                    self.showNetWorkError()
                }
                self.tableView.reloadData()
            })
        }

        tableView.reloadData()
        searchBar.resignFirstResponder()
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
        switch search.state {
        case .loading:  return 1
        case .notSearchYet: return 0
        case .noResults:  return 1
        case .results(let list): return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch search.state {
        case .notSearchYet:  fatalError("Should never get here")
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewIndentifier.LoadingCell, for: indexPath) as! LoadingCell
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        case .noResults:
            return tableView.dequeueReusableCell(withIdentifier: TableViewIndentifier.NothingResultCell, for: indexPath) as! NothingResultCell
        case .results(let list):
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewIndentifier.SearchResultCell, for: indexPath)
                as! SearchResultCell
            let searchResult = list[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch search.state {
        case .notSearchYet,.noResults,.loading:
            return nil
        case .results:
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
