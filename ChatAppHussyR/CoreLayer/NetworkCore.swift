//
//  NetworkCore.swift
//  ChatAppHussyR
//
//  Created by Данил on 26.04.2022.
//

import Foundation
import UIKit

protocol IRequest {
    var urlRequest: URLRequest? { get }
}

protocol IParser {
    associatedtype Model
    func parse(data: Data) -> Model?
}

protocol IRequestSender {
    func send<Parser>(
        configuration: RequestConfig<Parser>,
        complitionHandler: @escaping (Result<Parser.Model, Error>) -> Void
    )
    
    func fetchImageWithUrl(
        url: URL,
        complitionHandler: @escaping (Result<Data, Error>) -> Void
    )
}

struct RequestConfig<Parser> where Parser: IParser {
    let request: IRequest
    let parser: Parser
}

enum ParsingError: Error {
    case parsingError
}

class NetworkCore: IRequestSender {
    
    let session = URLSession.shared
    let queue = DispatchQueue.global()
    
    func send<Parser>(
        configuration: RequestConfig<Parser>,
        complitionHandler: @escaping (Result<Parser.Model, Error>) -> Void) where Parser: IParser {
            guard let request = configuration.request.urlRequest else { return }
            session.dataTask(with: request) { data, _, error in
                if let error = error {
                    complitionHandler(.failure(error))
                    return
                }
                guard let data = data,
                      let parsedModel = configuration.parser.parse(data: data)
                else {
                    complitionHandler(.failure(ParsingError.parsingError))
                    return
                }
                complitionHandler(.success(parsedModel))
            }.resume()
        }
    
    func fetchImageWithUrl(
        url: URL,
        complitionHandler: @escaping (Result<Data, Error>) -> Void
    ) {
        session.dataTask(with: url) { data, _, error in
            if let error = error {
                complitionHandler(.failure(error))
                return
            }
            guard let data = data
            else {
                
                complitionHandler(.failure(ParsingError.parsingError))
                return
            }
            complitionHandler(.success(data))
        }.resume()
    }
    
}
