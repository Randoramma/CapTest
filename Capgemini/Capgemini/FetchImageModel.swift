//
//  ViewModel.swift
//  Capgamani
//
//  Created by Randy McLain on 3/15/24.
//

import UIKit
import Combine

enum ViewModelErrors: Error {
    case URLStringWasInvalid
    case HTTPResponseCouldNotBeCast
    case HTTPStatusCodeError(code: Int)
}

protocol Fetchable: ObservableObject {
    init(session: URLSession)
    func updateImageForView(urlString: String)  async throws
}

final class FetchImageModel: Fetchable {

    // Publisher
    @Published var image: UIImage?
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func updateImageForView(urlString: String) async throws {
        
        guard let url: URL = URL(string: urlString) else {
            throw ViewModelErrors.URLStringWasInvalid
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpURLResponse: HTTPURLResponse = response as? HTTPURLResponse else {
            throw ViewModelErrors.HTTPResponseCouldNotBeCast
        }
        
        switch httpURLResponse.statusCode {
        case 200:
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        default: // other cases should be handled accordingly based on error type
            throw ViewModelErrors.HTTPStatusCodeError(code: httpURLResponse.statusCode)
        }
    }
}
