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
    private lazy var paginatedSearch = PaginatedImageSearch(update)
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var nextButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        search(nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let slideshow = segue.destination as? SlideshowViewController {
            let urls = collectionView.indexPathsForSelectedItems?.map {
                paginatedSearch.result[$0.section][$0.item].largeImageURL
            }
            slideshow.urls = urls ?? []
        }
    }
    
    @IBAction private func search(_ search: UITextField? = nil) {
        clearSelection()
        paginatedSearch = PaginatedImageSearch(search: search?.text, update)
        paginatedSearch.loadNextPage()
        collectionView.reloadData()
    }
    
    private func update() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        paginatedSearch.result.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        paginatedSearch.result[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Image", for: indexPath) as! ImageSearchCell
        cell.setImage(url: paginatedSearch.result[indexPath.section][indexPath.row].previewURL)
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

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard
            indexPath.section == paginatedSearch.result.indices.last,
            indexPath.row == paginatedSearch.result[indexPath.section].indices.last,
            !paginatedSearch.didLoadAllPages,
            !paginatedSearch.isLoading
        else { return }
        paginatedSearch.loadNextPage()
    }
}
