//
//  ImageSearchViewController.swift
//  test withings
//
//  Created by Pierre Gabory on 29/01/2022.
//

import UIKit

struct Response: Decodable {
    struct Hit: Decodable {
        let previewURL: URL
    }
    
    let hits: [Hit]
}

class ImageSearchViewController: UIViewController {
    var results: [Response.Hit] = [] { didSet { collectionView.reloadData() } }
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var nextButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
        collectionView.allowsMultipleSelection = true
        fetchImagesUrls()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let slideshow = segue.destination as? SlideshowViewController,
            let items = collectionView.indexPathsForSelectedItems?.map({ results[$0.item].previewURL })
        else {
            return
        }
        slideshow.urls = items
    }
    
    @IBAction private func fetchImagesUrls(search: UITextField? = nil) {
        updateNextButton()
        guard
            let request = URL(string: "https://pixabay.com/api/?key=18021445-326cf5bcd3658777a9d22df6f&q=\(search?.text ?? "")")
        else { return }
        URLSession.shared.dataTask(with: request) { data, _, error in
            do {
                if let error = error {
                    throw error
                }
                guard let data = data else {
                    throw NSError()
                }
                let results = try JSONDecoder().decode(Response.self, from: data).hits
                DispatchQueue.main.async { [weak self] in
                    self?.results = results
                }
            } catch {
                print(error)
                print(String(data: data ?? Data(), encoding: .utf8) ?? "no data")
            }
        }.resume()
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
        cell.contentView.backgroundColor = .white
        return cell
    }
}

extension ImageSearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateNextButton()
        collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = .blue
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateNextButton()
        collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = .white
    }
}
