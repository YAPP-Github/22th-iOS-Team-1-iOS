//
//  CafeGroupSeatLevel.swift
//  coffice
//
//  Created by 천수현 on 2023/07/22.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

enum CafeGroupSeatLevel {
  case unknown
  case isTrue
  case isFalse

  var iconName: String {
    switch self {
    case .unknown:
      return CofficeAsset.Asset.groupseatTrue44px.name // TODO: Unknown 추가 필요
    case .isTrue:
      return CofficeAsset.Asset.groupseatTrue44px.name
    case .isFalse:
      return CofficeAsset.Asset.groupseatFalse44px.name
    }
  }

  var text: String {
    return self == .isTrue ? "🪑 단체석" : ""
  }

  static func level(of level: Bool) -> CafeGroupSeatLevel {
    switch level {
    case true:
      return .isTrue
    case false:
      return .isFalse
    }
  }
}
