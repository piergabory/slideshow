//
//  ImageSearchViewController.swift
//  test withings
//
//  Created by Pierre Gabory on 29/01/2022.
//

import UIKit

class ImageSearchViewController: UIViewController {
    
    private let selectedColor = UIColor.blue
    private let deselectedColor = UIColor.white
    private let api = PixabayAPI()
    private var results: [PixabayAPI.Response.Hit] = [] { didSet { collectionView.reloadData() } }
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var nextButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
        fetchImagesUrls()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let slideshow = segue.destination as? SlideshowViewController {
            let urls = collectionView.indexPathsForSelectedItems?.map {
                results[$0.item].largeImageURL
            }
            slideshow.urls = urls ?? []
        }
    }
    
    @IBAction private func fetchImagesUrls(search: UITextField? = nil) {
        clearSelection()
        api.searchImages(search?.text) { [weak self] hits in
            DispatchQueue.main.async {
                self?.results = hits
            }
        }
    }
    
    private func clearSelection() {
        collectionView.allowsMultipleSelection = false
        collectionView.allowsMultipleSelection = true
        updateNextButton()
    }

    private func updateNextButton() {
        let numberOfSelectedItems = collectionView.indexPathsForSelectedItems?.count ?? 0
        nextButton.isEnabled = numberOfSelectedItems >= 2
    }
}
    
extension ImageSearchViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Image", for: indexPath) as! ImageSearchCell
        cell.setImage(url: results[indexPath.row].previewURL)
        cell.contentView.backgroundColor = deselectedColor
        return cell
    }
}

extension ImageSearchViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateNextButton()
        collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = selectedColor
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateNextButton()
        collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = deselectedColor
    }
}
