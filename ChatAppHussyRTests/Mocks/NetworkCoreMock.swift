//
//  NetworkCoreMock.swift
//  ChatAppHussyRTests
//
//  Created by Данил on 17.05.2022.
//

import Foundation
@testable import ChatAppHussyR

class NetworkCoreMock: IRequestSender {

    var invokedSend = false
    var invokedSendCount = 0

    func send<Parser>(
        configuration: RequestConfig<Parser>,
        complitionHandler: @escaping (Result<Parser.Model, Error>) -> Void
    ) {
        invokedSend = true
        invokedSendCount += 1
    }

    var invokedFetchImageWithUrl = false
    var invokedFetchImageWithUrlCount = 0
    var invokedFetchImageWithUrlParameters: (url: URL, Void)?
    var invokedFetchImageWithUrlParametersList = [(url: URL, Void)]()
    var stubbedFetchImageWithUrlComplitionHandlerResult: (Result<Data, Error>, Void)?

    func fetchImageWithUrl(
        url: URL,
        complitionHandler: @escaping (Result<Data, Error>) -> Void
    ) {
        invokedFetchImageWithUrl = true
        invokedFetchImageWithUrlCount += 1
        invokedFetchImageWithUrlParameters = (url, ())
        invokedFetchImageWithUrlParametersList.append((url, ()))
        if let result = stubbedFetchImageWithUrlComplitionHandlerResult {
            complitionHandler(result.0)
        }
    }
}
