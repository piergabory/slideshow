//
//  ImageFetcher.swift
//  test withings
//
//  Created by Pierre Gabory on 30/01/2022.
//

import Foundation
import UIKit.UIImage

final class ImageFetcher {
    
    func fetchImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil, let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }.resume()
    }
    
    func fetchImageSet(_ urls: [URL], completion: @escaping([UIImage]) -> Void) {
        let group = DispatchGroup()
        var images: [UIImage] = []
        for url in urls {
            group.enter()
            fetchImage(at: url) { image in
                if let image = image {
                    images.append(image)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(images)
        }
    }
}
