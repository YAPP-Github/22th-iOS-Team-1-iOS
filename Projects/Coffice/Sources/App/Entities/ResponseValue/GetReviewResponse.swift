//
//  ReviewsResponse.swift
//  coffice
//
//  Created by Min Min on 2023/07/13.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

typealias ReviewsResponse = [ReviewResponse]

struct ReviewResponse: Equatable {
  let reviewId: Int
  let memberId: Int
  let memberName: String
  var outletOption: ReviewOption.OutletOption
  var wifiOption: ReviewOption.WifiOption
  var noiseOption: ReviewOption.NoiseOption
  let createdDate: Date?
  let updatedDate: Date?
  let content: String

  init(
    reviewId: Int,
    memberId: Int,
    memberName: String,
    electricOutletLevel: String,
    wifiLevel: String,
    noiseLevel: String,
    createdAt: String,
    updatedAt: String,
    content: String
  ) {
    self.reviewId = reviewId
    self.memberId = memberId
    self.memberName = memberName

    outletOption = .few
    switch electricOutletLevel {
    case "SEVERAL":
      outletOption = .some
    case "MANY":
      outletOption = .enough
    default:
      outletOption = .few
    }

    wifiOption = .slow
    switch wifiLevel {
    case "FAST":
      wifiOption = .fast
    default:
      wifiOption = .slow
    }

    noiseOption = .quiet
    switch noiseLevel {
    case "NOISY":
      noiseOption = .loud
    case "NORMAL":
      noiseOption = .normal
    default:
      noiseOption = .quiet
    }

    self.content = content

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS+09:00"
    dateFormatter.locale = Locale(identifier: "ko_KR")
    createdDate = dateFormatter.date(from: createdAt)
    updatedDate = dateFormatter.date(from: updatedAt)
  }
}
