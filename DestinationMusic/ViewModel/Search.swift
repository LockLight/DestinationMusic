//
//  Search.swift
//  DestinationMusic
//
//  Created by locklight on 2018/5/9.
//  Copyright © 2018年 locklight. All rights reserved.
//

import Foundation
import UIKit

typealias SearchComplete = (Bool) -> Void

class Search{
    enum Category: Int {
        case all = 0
        case music = 1
        case software = 2
        case ebooks = 3
        
        var type:String{
            switch self {
            case .all: return ""
            case .music: return  "musicTrack"
            case .software: return "software"
            case .ebooks:   return "ebook"
            }
        }
    }
    
    enum State {
        case notSearchYet
        case loading
        case noResults
        case results([SearchResult])
    }
    
    private(set) var state:State = .notSearchYet
    private var dataTask:URLSessionDataTask? = nil
    
    func performSearch(for text:String ,category:Category ,completion:@escaping SearchComplete){
        if  !text.isEmpty{
            dataTask?.cancel()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            state = .loading
            
            let url = iTunesURL(searchText: text,category:category)
            print("URL:'\(url)'")
            
            let session = URLSession.shared
            
            dataTask = session.dataTask(with: url) { (data, response, error) in
                var success = false
                var newState = State.notSearchYet
                
                if let error = error as NSError? , error.code == -999{
                    print("Failure\(error)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200,
                    let data = data{
                    
                    var searchResults = self.parse(data: data)
                    if searchResults.isEmpty{
                        newState = .noResults
                    }else{
                        searchResults.sort(by: <)
                        newState = .results(searchResults)
                    }
                    
                    print("Success\(response!)")
                    success = true
                }
    
                    print("Failure:\(response!)")
                
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.state = newState
                    completion(success)
                }
            }
            dataTask?.resume()
        }
    }
    
    // MARK:- Private Methods
    func iTunesURL(searchText:String,category:Category) -> URL {
        let kind = category.type
    
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
}
