//
//  CustomHeaderView.swift
//  AppleMusicClone
//
//  Created by 123 on 12.11.2022.
//

import Foundation
import UIKit

class CustomFooterView: UIView {
    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var myLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupElements()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupElements() {
        addSubview(myLabel)
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            activityIndicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            activityIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
        
        NSLayoutConstraint.activate([
            myLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            myLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 8)
        ])
        
    }
    
    func showLoader() {
        activityIndicator.startAnimating()
        myLabel.text = "LOADING"
    }
    
    func hideIndicator() {
        activityIndicator.stopAnimating()
        myLabel.text = ""
    }
}
