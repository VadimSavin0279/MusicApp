//
//  Library.swift
//  AppleMusicClone
//
//  Created by 123 on 18.11.2022.
//

import SwiftUI
import URLImage

struct Library: View {
    let dataBase = CoreDataManager()
    @State var tracks = CoreDataManager().currentArrayOfFavouriteTracks
    
    @State var currentTrack: Track?
    
    var tabBarDelegate: TransitionDelegate
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { geometry in
                    HStack(spacing: 20) {
                        Button {
                            tabBarDelegate.increseView(viewModel: tracks[0])
                            currentTrack = tracks[0]
                        } label: {
                            Image("playButtonLight")
                                .frame(width: geometry.size.width / 2 - 10, height: 30)
                        }
                        
                        Button {
                            tracks = dataBase.currentArrayOfFavouriteTracks
                        } label: {
                            Image("repeatButton")
                                .frame(width: geometry.size.width / 2 - 10, height: 30)
                                .tint(Color.init(uiColor: UIColor.purple))
                        }
                    }
                }.padding().frame(height: 50)
                Divider().padding(.leading).padding(.trailing)
                List {
                    ForEach(tracks) { track in
                        LibraryCell(cell: track).gesture(TapGesture().onEnded({ _ in
                            let keyWindow = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.filter({$0.isKeyWindow}).first
                            let tabBarVC = keyWindow?.rootViewController as? MainTabBarController
                            tabBarVC?.trackView.delegate = self
                            currentTrack = track
                            self.tabBarDelegate.increseView(viewModel: track)
                        }))
                    }.onDelete(perform: delete)
                }.listStyle(.plain)
            }
            
        }
        
    }
    
    func delete(at offset: IndexSet) {
        var tracksForDelete: [Track] = []
        for index in offset {
            tracksForDelete.append(tracks[index])
        }
        
        tracks.remove(atOffsets: offset)
        
        for track in tracksForDelete {
            dataBase.deleteFavouriteTracks(track: track)
        }
    }
}

struct LibraryCell: View {
    var cell: Track
    var body: some View {
        HStack {
            if let str = cell.iconUrlString, let url = URL(string: str) {
                URLImage(url) { image in
                    image
                        .resizable()
                        .frame(width: 60, height: 60)
                        .cornerRadius(5)
                }
            } else {
                Image("").resizable().frame(width: 60, height: 60).cornerRadius(5)
            }
            VStack(alignment: .leading){
                Text(cell.trackName)
                Text(cell.artistName)
            }
        }
    }
}

extension Library: TrackMovingDelegate {
    func moveBackForPreviousTrack() {
        if let curTrack = currentTrack, let index = tracks.firstIndex(of: curTrack) {
            var prevTrack: Track
            if index - 1 == -1 {
                prevTrack = tracks[tracks.count - 1]
            } else {
                prevTrack = tracks[index - 1]
            }
            currentTrack = prevTrack
            tabBarDelegate.trackView.setup(viewModel: prevTrack)
        }
    }
    
    func moveForwardForPreviousTrack() {
        if let curTrack = currentTrack, let index = tracks.firstIndex(of: curTrack) {
            var nextTrack: Track
            if index + 1 == tracks.count {
                nextTrack = tracks[0]
            } else {
                nextTrack = tracks[index + 1]
            }
            currentTrack = nextTrack
            tabBarDelegate.trackView.setup(viewModel: nextTrack)
        }
    }
}

