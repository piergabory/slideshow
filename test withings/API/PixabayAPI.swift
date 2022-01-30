//
//  PixabayAPI.swift
//  test withings
//
//  Created by Pierre Gabory on 30/01/2022.
//

import Foundation
import UIKit

final class PixabayAPI {
    
    struct Response: Decodable {
        struct Hit: Decodable {
            let previewURL: URL
            let largeImageURL: URL
        }
        
        let hits: [Hit]
    }
    
    private let base = "https://pixabay.com/api/"
    private let key = "18021445-326cf5bcd3658777a9d22df6f"
    private var currentSearchTask: URLSessionTask?
    
    func searchImages(_ search: String?, page: Int, completion: @escaping ([Response.Hit]) -> Void) {
        var urlString = base + "?key=" + key
        if let search = search?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            urlString += "&q=" + search
        }
        urlString += "&page=\(page)"
        urlString += "&safesearch=true"
        print("Fetching \(page) for \(search).")
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        currentSearchTask?.cancel()
        currentSearchTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            defer { self?.currentSearchTask = nil }
            guard
                error == nil,
                let data = data,
                let results = try? JSONDecoder().decode(Response.self, from: data)
            else {
                print("Error")
                completion([])
                return
            }
            completion(results.hits)
        }
        currentSearchTask?.resume()
    }
}
