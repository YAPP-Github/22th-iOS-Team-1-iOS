//
//  LoginScreenCore.swift
//  Cafe
//
//  Created by Min Min on 2023/05/27.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import TCACoordinators

struct LoginScreen: Reducer {
  enum State: Equatable {
    /// 로그인 메인 페이지
    case main(Login.State)
  }

  enum Action: Equatable {
    case main(Login.Action)
  }

  var body: some ReducerOf<LoginScreen> {
    Scope(
      state: /State.main,
      action: /Action.main
    ) {
      Login()
    }
  }
}
