//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Giovanni Luidi Bruno on 01/01/21.
//  Copyright © 2021 Giovanni Luigi Bruno. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    private let reuseIdentifier = "imageCell"
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var noImagesLabel: UILabel!
    var pin: Pin?
    var annotation: MyAnnotation?
    var page: Int = 1
    
    var dataManager: DataManager {
        return DataManager.shared
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo Album"
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noImagesLabel.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: true)
        page = 1
        
        setupMapView()
        loadPhotos(page: page)
    }
    
    private func toggleNewCollectionButton(isDownloading: Bool) {
        newCollectionButton.isEnabled = !isDownloading
    }
    
    private func setupMapView() {
        if let annotation = annotation {
            mapView.addAnnotation(annotation)
            mapView.setCenter(annotation.coordinate, animated: false)
            mapView.setCameraZoomRange(MKMapView.CameraZoomRange(maxCenterCoordinateDistance: CLLocationDistance(2000)), animated: true)
        }
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        let size = (view.frame.width - 10)/3
        let cellSize = CGSize(width: size, height: size)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //.horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func loadPhotos(page: Int) {
        guard let pin = pin else {return}
        if pin.photos?.count ?? 0 == 0 {
            toggleNewCollectionButton(isDownloading: true)
            Client.shared.getPhotosFrom(lat: pin.latitude, lon: pin.longitude, page: page) { [weak self] result in
                self?.toggleNewCollectionButton(isDownloading: false)
                switch result {
                case .success(let response):
                    if response.dataResponse.photo.count == 0 {
                        self?.noImagesLabel.isHidden = false
                    } else {
                        for (i, photoResponse) in
                            response.dataResponse.photo.enumerated() {
                                guard let dataManager = self?.dataManager else {return}
                                let newPhoto = Photo(context: dataManager.viewContext)
                                pin.addToPhotos(newPhoto)
                                dataManager.saveContext()
                                Client.shared.getImage(from: photoResponse) { (data) in
                                    let indexPath = IndexPath(item: i, section: 0)
                                    let photo = pin.photos?.allObjects[i] as! Photo
                                    if data == nil {
                                        pin.removeFromPhotos(photo)
                                        dataManager.saveContext()
                                        if let _ = self?.collectionView.cellForItem(at: indexPath) {
                                            self?.collectionView.deleteItems(at: [indexPath])
                                        }
                                    } else {
                                        photo.imageData = data
                                        dataManager.saveContext()
                                        if let _ = self?.collectionView.cellForItem(at: indexPath) {
                                            self?.collectionView.reloadItems(at: [indexPath])
                                        }
                                    }
                                }
                        }
                        self?.collectionView.reloadData()
                    }
                case .failure:
                    self?.toggleNewCollectionButton(isDownloading: false)
                    let alert = UIAlertController(title: "Error", message: "Not able to load images for this location", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default) {_ in
                        self?.navigationController?.popViewController(animated: true)
                    } )
                    self?.present(alert, animated: true) {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func didTapNewCollection(_ sender: Any) {
        pin?.photos = nil
        dataManager.saveContext()
        collectionView.reloadData()
        page += 1
        loadPhotos(page: page)
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin?.photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoAlbumCollectionViewCell {
            
            if let photos = pin?.photos?.allObjects, let photo = photos[indexPath.row] as? Photo, let data = photo.imageData {
                cell.imageView.image = UIImage(data: data)
            } else {
                cell.imageView.image = UIImage(named: "placeholder")
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let photo = pin?.photos?.allObjects[indexPath.row] as? Photo {
            pin?.removeFromPhotos(photo)
            dataManager.saveContext()
            
            collectionView.deleteItems(at: [indexPath])
        }
    }
}
