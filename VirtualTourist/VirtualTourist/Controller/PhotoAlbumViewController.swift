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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    var pin: Pin?
    var annotation: MyAnnotation?
    
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
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        setupMapView()
        loadPhotos()
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
    
    private func loadPhotos() {
        guard let pin = pin else {return}
        if pin.photos?.count ?? 0 == 0 {
            Client.shared.getPhotosFrom(lat: pin.latitude, lon: pin.longitude) { [weak self] result in
                switch result {
                case .success(let response):
                    for photoResponse in response.dataResponse.photo {
                        Client.shared.getImage(from: photoResponse) { (data) in
                            guard let dataManager = self?.dataManager else {return}
                            let newPhoto = Photo(context: dataManager.viewContext)
                            newPhoto.imageData = data as NSObject?
                            pin.addToPhotos(newPhoto)
                            dataManager.saveContext()
                            
                            self?.collectionView.reloadData()
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    
}


extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin?.photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoAlbumCollectionViewCell {
            
            if let photos = pin?.photos?.allObjects, let photo = photos[indexPath.row] as? Photo, let data = photo.imageData as? Data {
                cell.imageView.image = UIImage(data: data)
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
}
