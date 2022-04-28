//
//  NetworkService.swift
//  ChatAppHussyR
//
//  Created by Данил on 26.04.2022.

import Foundation
import UIKit

struct Page: Codable {
    let hits: [Hit]
}

// MARK: - Hit

struct Hit: Codable {
    let largeImageURL: String
    let previewURL: String
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
        topic: String,
        page: Int
    ) {
        let apiKey = Constants.APIKEY
        if var urlComponents = URLComponents(string: "https://pixabay.com/api") {
            urlComponents.query = "key=\(apiKey)&q=\(topic)&image_type=photo&page=\(page)&per_page=\(numberOfPhotos)"
            guard let url = urlComponents.url else { return }
            urlRequest = URLRequest(url: url)
        } else {
            print("incorrect")
            return
        }
    }
}

struct Photo {
    var previewUrl: String
    var largeImageURL: String
}

protocol NetworkServiceProtocol {
    func getPictures(
        numberOfPhotos: Int,
        topic: String,
        page: Int,
        complitionHandler: @escaping (Result<[Photo], Error>) -> Void
    )
    func loadPicture(
        url: String,
        complitionHandler: @escaping (Result<Data, Error>) -> Void
    )
}

class NetworkService: NetworkServiceProtocol {
    
    let networkCore: IRequestSender
    
    init() {
        networkCore = NetworkCore()
    }
    
    func getPictures(
        numberOfPhotos: Int,
        topic: String,
        page: Int,
        complitionHandler: @escaping (Result<[Photo], Error>) -> Void
    ) {
        let picturesParser = PicturesParser()
        var request = PicturesRequest()
        request.makeRequest(numberOfPhotos: numberOfPhotos, topic: topic, page: page)
        let config = RequestConfig(request: request, parser: picturesParser)
        self.networkCore.send(configuration: config) { result in
            switch result {
            case .failure(let error):
                complitionHandler(.failure(error))
            case .success(let model):
                #if NETWORKLOG
                print("load page number \(page)")
                #endif
                let photos = model.hits.map { Photo(previewUrl: $0.previewURL, largeImageURL: $0.largeImageURL) }
                complitionHandler(.success(photos))
            }
        }
    }
    
    func loadPicture(
        url: String,
        complitionHandler: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = URL(string: url) else { return }
        
        self.networkCore.fetchImageWithUrl(url: url) { result in
            switch result {
            case .failure(let error):
                complitionHandler(.failure(error))
            case .success(let data):
                complitionHandler(.success(data))
            }
            
        }
    }
}
