//
//  SlideshowViewController.swift
//  test withings
//
//  Created by Pierre Gabory on 29/01/2022.
//

import UIKit

final class SlideshowViewController: UIViewController {
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var imageView: UIImageView!
    
    var urls: [URL] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if urls.count < 2 {
            navigationController?.popViewController(animated: animated)
        }
        prepareSlideShow(with: urls)
        
    }
    
    private func prepareSlideShow(with urls: [URL]) {
        let dispatch = DispatchGroup()
        var images: [UIImage?] = Array(repeating: nil, count: urls.count)
        for (index, url) in urls.enumerated() {
            dispatch.enter()
            URLSession.shared.dataTask(with: url) { data, _, error in
                defer { dispatch.leave() }
                guard let data = data, error == nil else {
                    return
                }
                images[index] = UIImage(data: data)
            }.resume()
        }
        dispatch.notify(queue: .main) { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.startSlideshow(with: images.compactMap { $0 })
        }
    }
    
    private func startSlideshow(with imageSet: [UIImage]) {
        imageView.image = imageSet.first
        let transition: UIView.AnimationOptions = [
            .transitionCurlUp,
            .transitionCurlDown,
            .transitionCrossDissolve,
            .transitionFlipFromLeft,
            .transitionFlipFromBottom,
            .transitionFlipFromRight,
            .transitionFlipFromTop
        ].randomElement()!
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            guard imageSet.count > 1, let view = self?.imageView else {
                self?.navigationController?.popViewController(animated: true)
                return
            }
            let imageSet = Array(imageSet[1...])
            UIView.transition(with: view, duration: 1, options: transition) {
                view.image = imageSet.first
            } completion: { [weak self] _ in
                self?.startSlideshow(with: imageSet)
            }
        }
    }
}
