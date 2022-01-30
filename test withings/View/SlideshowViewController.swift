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

    private let imageFetcher = ImageFetcher()
    private let transitions: [UIView.AnimationOptions] = [
        .transitionCurlUp,
        .transitionCurlDown,
        .transitionCrossDissolve,
        .transitionFlipFromLeft,
        .transitionFlipFromBottom,
        .transitionFlipFromRight,
        .transitionFlipFromTop
    ]

    var urls: [URL] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if urls.count < 2 {
            navigationController?.popViewController(animated: animated)
        }
        prepareSlideShow(with: urls)
    }
    
    private func prepareSlideShow(with urls: [URL]) {
        imageFetcher.fetchImageSet(urls) { [weak self] images in
            self?.activityIndicator.stopAnimating()
            self?.imageView.image = images.first
            self?.showNextSlide(in: Array(images.dropFirst()))
        }
    }
    
    private func showNextSlide(in slides: [UIImage]) {
        transition(to: slides.first) { [weak self] in
            if slides.isEmpty {
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.showNextSlide(in: Array(slides.dropFirst()))
            }
        }
    }
    
    private func transition(to nextSlide: UIImage?, completion: @escaping () -> Void) {
        let transition = transitions.randomElement()!
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            guard
                let imageView = self?.imageView,
                let image = nextSlide
            else {
                completion()
                return
            }
            UIView.transition(with: imageView, duration: 1, options: transition) {
                imageView.image = image
            } completion: { _ in
                completion()
            }
        }
    }
}
