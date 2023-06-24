//
//  PlaceAPIClient.swift
//  coffice
//
//  Created by 천수현 on 2023/06/22.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Dependencies
import Foundation
import Network

struct SearchPlaceAPIClient: DependencyKey {
  static var liveValue: SearchPlaceAPIClient = .liveValue

  func fetchDefaultPlaces(page: Int, size: Int, sort: SortDescriptor) async throws -> [SearchPlaceResponseDTO] {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/places"
    urlComponents?.queryItems = [
      .init(name: "page", value: String(page)),
      .init(name: "size", value: String(size)),
      .init(name: "sort", value: sort.name)
    ]

    guard let request = urlComponents?.toURLRequest(method: .get)
    else { throw CoreNetworkError.requestConvertFailed }

    let response: [SearchPlaceResponseDTO] = try await coreNetwork.dataTask(request: request)
    return response
  }

  func fetchPlaces(requestValue: SearchPlaceRequestDTO) async throws -> [SearchPlaceResponseDTO] {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/places/search"

    guard let requestBody = try? JSONEncoder().encode(requestValue)
    else { throw CoreNetworkError.jsonEncodeFailed }

    guard let request = urlComponents?.toURLRequest(method: .post, httpBody: requestBody)
    else { throw CoreNetworkError.requestConvertFailed }

    let response: [SearchPlaceResponseDTO] = try await coreNetwork.dataTask(request: request)
    return response
  }

  func fetchPlace(placeId: Int) async throws -> SearchPlaceResponseDTO {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/places/\(placeId)"

    guard let request = urlComponents?.toURLRequest(method: .get)
    else { throw CoreNetworkError.requestConvertFailed }

    let response: SearchPlaceResponseDTO = try await coreNetwork.dataTask(request: request)
    return response
  }
}

extension DependencyValues {
  var placeAPIClient: SearchPlaceAPIClient {
    get { self[SearchPlaceAPIClient.self] }
    set { self[SearchPlaceAPIClient.self] = newValue }
  }
}

extension SearchPlaceAPIClient {
  enum SortDescriptor {
    case ascending
    case descending

    var name: String {
      switch self {
      case .ascending:
        return "asc"
      case .descending:
        return "desc"
      }
    }
  }
}