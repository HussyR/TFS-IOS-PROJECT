//
//  NetworkService.swift
//  ChatAppHussyR
//
//  Created by Данил on 26.04.2022.
//
//
//protocol IRequest {
//    var urlRequest: URLRequest? { get }
//}
//
//protocol IParser {
//    associatedtype Model
//    func parse(data: Data) -> Model?
//}

import Foundation
import UIKit

struct Page: Codable {
    let hits: [Hit]
}

// MARK: - Hit
struct Hit: Codable {
    let largeImageURL: String
}

struct PicturesParser: IParser {
    typealias Model = Page
    func parse(data: Data) -> Model? {
        do {
            return try JSONDecoder().decode(Page.self, from: data)
        } catch {
            return nil
        }
    }
}

struct PicturesRequest: IRequest {
    var urlRequest: URLRequest?
    
    mutating func makeRequest(
        numberOfPhotos: Int,
        topic: String
    ) {
        let apiKey = Constants.APIKEY
        if var urlComponents = URLComponents(string: "https://pixabay.com/api") {
            urlComponents.query = "key=\(apiKey)&q=\(topic)&per_page=\(numberOfPhotos)"
            guard let url = urlComponents.url else { return }
            urlRequest = URLRequest(url: url)
        } else {
            return
        }
    }
}

struct Photo {
    var photoUrl: String
}

class NetworkService {
    
    let networkCore: IRequestSender
    
    init() {
        networkCore = NetworkCore()
    }
    
    func getPictures(
        numberOfPhotos: Int,
        topic: String,
        complitionHandler: @escaping (Result<[Photo],Error>) -> Void,
        on queue: DispatchQueue
    ) {
        let picturesParser = PicturesParser()
        var request = PicturesRequest()
        request.makeRequest(numberOfPhotos: numberOfPhotos, topic: topic)
        
        let config = RequestConfig(request: request, parser: picturesParser)
        
        networkCore.send(configuration: config) { result in
            switch result {
            case .failure(let error):
                complitionHandler(.failure(error))
            case .success(let model):
                let photos = model.hits.map { Photo(photoUrl: $0.largeImageURL) }
                queue.async {
                    complitionHandler(.success(photos))
                }
            }
        }
    }
    
    func loadPicture(
        url: String,
        complitionHandler: @escaping (Result<UIImage,Error>) -> Void,
        on queue: DispatchQueue
    ) {
        guard let url = URL(string: url) else { return }
        networkCore.fetchImageWithUrl(url: url) { result in
            switch result {
            case .failure(let error):
                complitionHandler(.failure(error))
            case .success(let data):
                queue.async {
                    guard let image = UIImage(data: data) else { return }
                    complitionHandler(.success(image))
                }
            }
        
        }
    }
    
}
