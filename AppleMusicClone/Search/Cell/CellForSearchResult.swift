//
//  CellForSearchResult.swift
//  AppleMusicClone
//
//  Created by 123 on 09.11.2022.
//

import UIKit
import CoreData

class CellForSearchResult: UITableViewCell {
 
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var addToFavouriteButton: UIButton!
    @IBOutlet weak var trackIcon: UIImageView!
    
    var model: Track?
    let dataBase = CoreDataManager()
    
    override func awakeFromNib() {
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        trackIcon.layer.cornerRadius = trackIcon.bounds.height * 0.16
    }
    
    func configureCellForSearchResult(viewModel: Track) {
        trackName.text = viewModel.trackName
        albumName.text = viewModel.artistName + " | " + (viewModel.collectionName ?? "")
        guard let url = URL(string: viewModel.iconUrlString ?? "") else { return }
        trackIcon.sd_setImage(with: url)
        
        if dataBase.currentArrayOfFavouriteTracks.contains(viewModel) {
            addToFavouriteButton.isHidden = true
        } else {
            addToFavouriteButton.isHidden = false
        }
        
        model = viewModel
    }
    
    @IBAction func addToLibraryAction(_ sender: UIButton) {
        if let model = model {
            dataBase.addFavouriteTracks(track: model)
            sender.isHidden = true
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        switch selected {
        case true:
            backgroundColor = UIColor(named: "whiteAndBlackLight")
        case false:
            backgroundColor = UIColor(named: "whiteAndBlack")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackIcon.image = UIImage()
    }
}
