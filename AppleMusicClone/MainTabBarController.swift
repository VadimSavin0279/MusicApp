//
//  MainTabBarVController.swift
//  AppleMusicClone
//
//  Created by 123 on 08.11.2022.
//

import UIKit
import SwiftUI

protocol TransitionDelegate: AnyObject {
    func reduceView()
    func increseView(viewModel: Track?)
    var trackView: TrackDetailView { get }
}

class MainTabBarController: UITabBarController {
    
    let searchViewController = SearchViewController()
    
    var maximizeAnchor: NSLayoutConstraint!
    var minimizeAnchor: NSLayoutConstraint!
    var bottomAnchor: NSLayoutConstraint!
    
    var a: Float = 0
    
    var trackView: TrackDetailView = {
        guard let trackView = UINib(nibName: "TrackDetailView", bundle: nil).instantiate(withOwner: nil).first as? TrackDetailView else { return TrackDetailView() }
        return trackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navVC1 = UINavigationController(rootViewController: searchViewController)
        let libraryVC = Library(tabBarDelegate: self)
        let hostVC = UIHostingController(rootView: libraryVC)
        hostVC.tabBarItem.image = UIImage(named: "libraryIcon")
        hostVC.navigationItem.title = "gf"
        
        let navVC2 = UINavigationController(rootViewController: hostVC)
        viewControllers = [navVC1, navVC2]
        
        searchViewController.transitionDelegate = self
        
        setupTabBarItem(controller: navVC1,
                        image: UIImage(named: "searchIcon"),
                        selectedImage: UIImage(named: "searchSelectedImage")?.withRenderingMode(.alwaysOriginal),
                        title: "Search")
        setupTabBarItem(controller: navVC2,
                        image: UIImage(named: "libraryIcon"),
                        selectedImage: UIImage(named: "librarySelectedImage")?.withRenderingMode(.alwaysOriginal),
                        title: "Library")
        setupTabBar()
        setupDetailView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        a = Float(trackView.bounds.height) - Float(trackView.volumeSlider.frame.origin.y) - 60
    }
    
    func setupTabBar() {
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        tabBar.backgroundColor = UIColor(named: "whiteAndBlack")
        
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBar.layer.cornerRadius = 20
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowOpacity = 0.7
        tabBar.layer.shadowRadius = 10
        tabBar.layer.shadowColor = UIColor.black.cgColor
    }
    
    func setupTabBarItem(controller: UINavigationController, image: UIImage?, selectedImage: UIImage?, title: String) {
        controller.tabBarItem.image = image
        controller.viewControllers.first?.navigationItem.title = title
        controller.navigationBar.prefersLargeTitles = true
        controller.tabBarItem.selectedImage = selectedImage
        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
    
    func setupDetailView() {
        
        trackView.delegate = searchViewController
        trackView.transitionDelegate = self
        trackView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(trackView, belowSubview: tabBar)
        
        minimizeAnchor = trackView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        maximizeAnchor = trackView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        bottomAnchor = trackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.bounds.height)
        
        NSLayoutConstraint.activate([
            maximizeAnchor,
            trackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor])
    }
}

extension MainTabBarController: TransitionDelegate {
    
    func reduceView() {
        bottomAnchor.constant = view.bounds.height
        maximizeAnchor.isActive = false
        minimizeAnchor.isActive = true
        
        trackView.reduceButton.isHidden = true
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
            self.tabBar.alpha = 1
            self.trackView.miniTrackView.alpha = 1
        }
    }
    
    func increseView(viewModel: Track?) {
        bottomAnchor.constant = 50
        maximizeAnchor.constant = CGFloat(a)
        maximizeAnchor.isActive = true
        minimizeAnchor.isActive = false
        
        trackView.reduceButton.isHidden = false
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
            self.tabBar.alpha = 0
            self.trackView.miniTrackView.alpha = 0
        }
        guard let viewModel = viewModel else { return }
        trackView.setup(viewModel: viewModel)
    }
}
