//
//  BottomSheetCore.swift
//  coffice
//
//  Created by 천수현 on 2023/07/11.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct BottomSheetReducer: Reducer {
  struct State: Equatable {
    static let initialState: Self = .init()

  }

  enum Action: Equatable {
    case confirmButtonTapped
    case cancelButtonTapped
  }

  var body: some ReducerOf<BottomSheetReducer> {
    Reduce { state, action in
      switch action {
      default:
        return .none
      }
    }
  }
}
