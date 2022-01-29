//
//  ImageSearchCell.swift
//  test withings
//
//  Created by Pierre Gabory on 29/01/2022.
//

import UIKit

final class ImageSearchCell: UICollectionViewCell {
    
    @IBOutlet private var imageView: UIImageView!
    
    func setImage(url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil, let data = data, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async { [weak self] in
                self?.imageView.image = image
            }
        }.resume()
    }
}
