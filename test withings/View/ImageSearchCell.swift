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
        ImageFetcher().fetchImage(at: url) { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
    }
}
