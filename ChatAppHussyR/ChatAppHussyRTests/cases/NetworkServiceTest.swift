//
//  NetworkServiceTest.swift
//  ChatAppHussyRTests
//
//  Created by Данил on 17.05.2022.
//

import XCTest
@testable import ChatAppHussyR

class NetworkServiceTest: XCTestCase {

    let mock = NetworkCoreMock()
    
    func testLoadPictures() {
        // given
        let sut = build()
        let stringURL = "https://www.google.ru/"
        mock.stubbedFetchImageWithUrlComplitionHandlerResult = (Result.success(Data()), ())
        // when
        sut.loadPicture(url: stringURL) { _ in
            
        }
        guard let url = URL(string: stringURL),
              let paramURL = mock.invokedFetchImageWithUrlParameters?.url else {
            return
        }
        // then
        XCTAssertTrue(mock.invokedFetchImageWithUrl)
        XCTAssertEqual(mock.invokedFetchImageWithUrlCount, 1)
        XCTAssertEqual(paramURL, url)
    }
    
    func testGetPictures() {
        // given
        let sut = build()
        
        // when
        sut.getPictures(numberOfPhotos: 10,
                        topic: "Test",
                        page: 10) { _ in
            
        }
        // then
        XCTAssertTrue(mock.invokedSend)
        XCTAssertEqual(mock.invokedSendCount, 1)
    }
    
    private func build() -> NetworkService {
        let networkService = NetworkService(networkCore: mock)
        return networkService
    }

}
