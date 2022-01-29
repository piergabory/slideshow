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

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
    }
    
    @IBAction private func fetchImagesUrls(search: UITextField? = nil) {
        let request = "https://pixabay.com/api/?key=18021445-326cf5bcd3658777a9d22df6f&q=\(search?.text ?? "")"
        URLSession.shared.dataTask(with: URL(string: request)!) { data, _, error in
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
}
    
extension ImageSearchViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Image", for: indexPath) as! ImageSearchCell
        cell.setImage(url: results[indexPath.row].previewURL)
        return cell
    }
}
