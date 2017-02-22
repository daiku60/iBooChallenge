//
//  ImagesListViewController.swift
//  iBooChallenge
//
//  Created by Jordi Serra i Font on 19/2/17.
//  Copyright (c) 2017 kudai. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so you can apply
//  clean architecture to your iOS and Mac projects, see http://clean-swift.com
//

import UIKit

protocol ImagesListViewControllerInput {
    func display(_ presentable: ImagesList.Search.Presentable)
}

protocol ImagesListViewControllerOutput {
    func searchImages(request: ImagesList.Search.Request)
}

class ImagesListViewController: UIViewController, ImagesListViewControllerInput {
    
    enum Constants {
        static let ImageCollectionViewCellIdentifier: String = "ImageCollectionViewCellIdentifier"
        static let SpinnerCellIdentifer: String = "SpinnerCellIdentifier"
    }
    
    var output: ImagesListViewControllerOutput!
    var router: ImagesListRouter!
    
    var viewModel: ImagesList.Search.Presentable.ViewModel?
    var currentPage: Int = 1
    
    // MARK: - UI Elements
    
    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "iBOO Challenge"
        
        ImagesListConfigurator.sharedInstance.configure(viewController: self)
        view.backgroundColor = .white
        layoutSubviews()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            ImageCollectionViewCell.self,
            forCellWithReuseIdentifier: Constants.ImageCollectionViewCellIdentifier)
        collectionView.register(
            SpinnerCell.self,
            forCellWithReuseIdentifier: Constants.SpinnerCellIdentifer)
        
        searchImagesOnLoad()
    }
    
    private func layoutSubviews() {
        view.addSubview(collectionView)
        view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  
        collectionView.leadingAnchor
            .constraint(equalTo: view.leadingAnchor)
            .isActive = true
        collectionView.topAnchor
            .constraint(equalTo: view.topAnchor)
            .isActive = true
        collectionView.trailingAnchor
            .constraint(equalTo: view.trailingAnchor)
            .isActive = true
        collectionView.bottomAnchor
            .constraint(equalTo: view.bottomAnchor)
            .isActive = true
        
        spinner.isHidden = true
    }
    
    // MARK: - Event handling
    
    func searchImagesOnLoad() {
        // NOTE: Ask the Interactor to do some work
        let request = ImagesList.Search.Request(
            searchTerm: "Barcelona City",
            currentPage: currentPage
        )
        
        spinner.isHidden = false
        output.searchImages(request: request)
    }
    
    // MARK: - Display logic
    
    func display(_ presentable: ImagesList.Search.Presentable) {
        // NOTE: Display the result from the Presenter
        spinner.isHidden = true
        
        switch presentable {
        case .success(let viewModel):
            if var currentVM = self.viewModel {
                currentVM.images = currentVM.images + viewModel.images
                self.viewModel = currentVM
                collectionView.performBatchUpdates({
                    self.collectionView.reloadSections([0])
                }, completion: nil)
            } else {
                self.viewModel = viewModel
                collectionView.reloadData()
            }
        case .error(let error):
            displayError(error)
        }
    }
    
    func displayError(_ error: ImagesList.Search.Presentable.ErrorViewModel) {
        // TODO: Display error
    }
    
    func isLastCell(_ indexPath: IndexPath) -> Bool {
        guard let viewModel = viewModel else { return false  }
        return indexPath.item == viewModel.images.count
    }
}

extension ImagesListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = viewModel?.images.count else { return 0 }
        return count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let viewModel = viewModel else { fatalError() }
        if !isLastCell(indexPath) {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Constants.ImageCollectionViewCellIdentifier,
                for: indexPath
            ) as! ImageCollectionViewCell
            
            cell.configure(for: viewModel.images[indexPath.item])
            cell.delegate = self
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Constants.SpinnerCellIdentifer,
                for: indexPath
            ) as! SpinnerCell
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isLastCell(indexPath) {
            currentPage += 1
            searchImagesOnLoad()
        }
    }
}

extension ImagesListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isLastCell(indexPath) {
            return CGSize(width: self.view.frame.size.width, height: 100)
        }
        return CGSize(width: self.view.frame.size.width, height: 200)
    }
}

extension ImagesListViewController: ImageCollectionViewCellDelegate {
    func switchChanged(sender: ImageCollectionViewCell, isOn: Bool) {
        guard let indexPath = collectionView.indexPath(for: sender) else { return }
        guard var viewModel = self.viewModel else { return }
        
        viewModel.images[indexPath.item].isFavourite = isOn
        self.viewModel = viewModel
    }
}
