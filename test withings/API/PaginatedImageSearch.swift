//
//  PaginatedImageSearch.swift
//  test withings
//
//  Created by Pierre Gabory on 30/01/2022.
//

import Foundation

final class PaginatedImageSearch {
    
    typealias Hit = PixabayAPI.Response.Hit
    private(set) var result: [[Hit]] = []
    private(set) var isLoading = false
    private(set) var didLoadAllPages = false
    
    private let update: () -> Void
    private let search: String?
    private let api = PixabayAPI()
    
    init(search: String? = nil, _ update: @escaping () -> Void) {
        self.search = search
        self.update = update
    }

    func loadNextPage() {
        if isLoading || didLoadAllPages { return }
        isLoading = true
        let page = result.count
        result.append([])
        api.searchImages(search, page: page + 1) { [weak self] result in
            self?.result[page] = result
            self?.didLoadAllPages = result.isEmpty
            self?.update()
            self?.isLoading = false
        }
    }
}
