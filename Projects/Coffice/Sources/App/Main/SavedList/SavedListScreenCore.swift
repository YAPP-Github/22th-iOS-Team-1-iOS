//
//  SearchScreenCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import TCACoordinators

struct SearchScreen: ReducerProtocol {
  enum State: Equatable {
    /// 메인 페이지
    case cafeMap(CafeMapCore.State)
  }

  enum Action: Equatable {
    case cafeMap(CafeMapCore.Action)
  }

  var body: some ReducerProtocolOf<SearchScreen> {
    Scope(
      state: /State.cafeMap,
      action: /Action.cafeMap
    ) {
      CafeMapCore()
    }
  }
}