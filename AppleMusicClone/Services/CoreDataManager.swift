//
//  CoreData + Extension.swift
//  AppleMusicClone
//
//  Created by 123 on 07.03.2023.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var currentArrayOfFavouriteTracks: [Track] {
        return getFavouriteTracks()
    }
    
    private func getFavouriteTracks() -> [Track] {
        let fetchReq = FavouriteTrack.fetchRequest()
        do {
            let favouriteTracks = try context.fetch(fetchReq)
            var results: [Track] = []
            for favouriteTrack in favouriteTracks {
                let track = Track(trackName: favouriteTrack.trackName ?? "",
                                  collectionName: favouriteTrack.collectionName ?? "",
                                  artistName: favouriteTrack.artistName ?? "",
                                  iconUrlString: favouriteTrack.iconUrlString ?? "",
                                  audioUrl: favouriteTrack.audioUrl ?? "")
                results.append(track)
            }
            return results.reversed()
        } catch {
            print(error)
        }
        return []
    }
    
    func addFavouriteTracks(track: Track) {
        guard let entity = NSEntityDescription.entity(forEntityName: "FavouriteTrack", in: context),
                let object = NSManagedObject(entity: entity, insertInto: context) as? FavouriteTrack else { return }
        object.artistName = track.artistName
        object.trackName = track.trackName
        object.audioUrl = track.audioUrl
        object.collectionName = track.collectionName
        object.iconUrlString = track.iconUrlString
        
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func deleteFavouriteTracks(track: Track) {
        let fetchReq = FavouriteTrack.fetchRequest()
        fetchReq.predicate = NSPredicate(format: "trackName = %@ AND artistName = %@ AND audioUrl = %@ AND iconUrlString = %@", argumentArray: [track.trackName, track.artistName, track.audioUrl, track.iconUrlString ?? ""])
        do {
            let favouriteTracks = try context.fetch(fetchReq)
            if let favouriteTrack = favouriteTracks.first {
                context.delete(favouriteTrack)
                try context.save()
            }
        } catch {
            print(error)
        }
    }
}
