//
//  SearchWorker.swift
//  AppleMusicClone
//
//  Created by 123 on 10.11.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

class SearchService {
    let manager = APIManager()
    func fetchTracks(searchText: String,
                     completion: @escaping (ResultOfSearch) -> (),
                     completionForError: @escaping () -> Void) {
        manager.sendRequest(with: SearchProvider.getTrack(searchText), decodeType: ResultOfSearch.self) { response in
            switch response {
            case .success(let result):
                completion(result)
            case .failure(let error):
                print(error)
                completionForError()
            }
        }
    }
}
