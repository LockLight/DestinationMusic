//
//  SearchResult.swift
//  DestinationMusic
//
//  Created by locklight on 2018/4/28.
//  Copyright © 2018年 locklight. All rights reserved.
//

import Foundation

class ResultArray: Codable {
    var resultCount = 0
    var results = [SearchResult]()
}

class SearchResult:Codable, CustomStringConvertible {
    var kind:String?
    var artistName = ""
    var trackName:String?
    var trackPrice:Double?
    var trackViewUrl:String?
    var collectionName:String?
    var collectionViewUrl:String?
    var collectionPrice:Double?
    var itemPrice:Double?
    var itemGenre:String?
    var bookGenre:[String]?
    var currency = ""
    var imageSmall = ""
    var imageLarge = ""
    
    enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case itemGenre = "primaryGenreName"
        case bookGenre = "genres"
        case itemPrice = "price"
        case kind, artistName, currency
        case trackName, trackPrice, trackViewUrl
        case collectionName, collectionViewUrl, collectionPrice
    }
    
    var name:String {
        return trackName ?? collectionName ?? ""
    }
    
    var storeURL:String {
        return trackViewUrl ?? collectionViewUrl ?? ""
    }
    
    var price:Double {
        return trackPrice ?? collectionPrice ?? 0.0
    }
    
    var genre:String {
        if let genre = itemGenre {
            return genre
        } else if let genres = bookGenre {
            return genres.joined(separator: ", ")
        }
        return ""
    }
    
    var type:String {
        let kind = self.kind ?? "audiobook"
        switch kind {
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default: break
        }
        return "Unknown"
    }
    
    var description:String {
        return "Kind: \(kind ?? ""), Name: \(name), Artist Name: \(artistName)\n"
    }
    
    static func < (minore:SearchResult,maggiore:SearchResult) -> Bool{
        return minore.name.localizedStandardCompare(maggiore.name) == .orderedAscending
    }
}


/*
 {
 "resultCount": 50,
 "results": [
    {
    "wrapperType": "track",
    "kind": "song",
    "artistId": 3996865,
    "collectionId": 579372950,
    "trackId": 579373079,
    "artistName": "Metallica",
    "collectionName": "Metallica",
    "trackName": "Enter Sandman",
    "collectionCensoredName": "Metallica",
    "trackCensoredName": "Enter Sandman",
    "artistViewUrl": "https://itunes.apple.com/us/artist/metallica/3996865?uo=4",
    "collectionViewUrl": "https://itunes.apple.com/us/album/enter-sandman/579372950?i=579373079&uo=4",
    "trackViewUrl": "https://itunes.apple.com/us/album/enter-sandman/579372950?i=579373079&uo=4",
    "previewUrl": "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/Music7/v4/bd/fd/e4/bdfde4e4-5407-9bb0-e632-edbf079bed21/mzaf_907706799096684396.plus.aac.p.m4a",
    "artworkUrl30": "https://is1-ssl.mzstatic.com/image/thumb/Music/v4/0b/9c/d2/0b9cd2e7-6e76-8912-0357-14780cc2616a/source/30x30bb.jpg",
    "artworkUrl60": "https://is1-ssl.mzstatic.com/image/thumb/Music/v4/0b/9c/d2/0b9cd2e7-6e76-8912-0357-14780cc2616a/source/60x60bb.jpg",
    "artworkUrl100": "https://is1-ssl.mzstatic.com/image/thumb/Music/v4/0b/9c/d2/0b9cd2e7-6e76-8912-0357-14780cc2616a/source/100x100bb.jpg",
    "collectionPrice": 9.99,
    "trackPrice": 1.29,
    "releaseDate": "1991-07-29T07:00:00Z",
    "collectionExplicitness": "notExplicit",
    "trackExplicitness": "notExplicit",
    "discCount": 1,
    "discNumber": 1,
    "trackCount": 12,
    "trackNumber": 1,
    "trackTimeMillis": 331560,
    "country": "USA",
    "currency": "USD",
    "primaryGenreName": "Metal",
    "isStreamable": true
    },
 }
 */
