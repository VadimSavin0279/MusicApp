//
//  SearchProvider.swift
//  AppleMusicClone
//
//  Created by 123 on 10.11.2022.
//

import Foundation
import Alamofire

protocol Provider {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders { get }
    var params: Parameters { get }
}

enum SearchProvider: Provider {
    case getTrack(String)
}

extension SearchProvider {
    
    var baseURL: String {
        return "https://itunes.apple.com"
    }
    
    var path: String {
        switch self {
        case .getTrack:
            return "/search"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getTrack:
            return .get
        }
    }
    
    var headers: HTTPHeaders {
        return HTTPHeaders([])
    }
    
    var params: Parameters {
        switch self {
        case .getTrack(let textForSearching):
            return ["term": textForSearching, "media": "music"]
        }
    }
}
