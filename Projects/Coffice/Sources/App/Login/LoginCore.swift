//
//  LoginCore.swift
//  Cafe
//
//  Created by Min Min on 2023/05/27.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import FirebaseAnalytics
import KakaoSDKAuth
import KakaoSDKUser
import Network

struct Login: ReducerProtocol {
  struct State: Equatable {
    static let initialState: State = .init(isOnboarding: false)

    var isOnboarding = false
    let title = "Login"

    init() { }

    init(isOnboarding: Bool) {
      self.isOnboarding = isOnboarding
    }
  }

  enum Action: Equatable {
    case onAppear
    case useAppAsNonMember
    case kakaoLoginButtonClicked
    case appleLoginButtonClicked(token: String)
    case dismissLoginPage
  }

  @Dependency(\.loginClient) private var loginClient

  var body: some ReducerProtocolOf<Login> {
    Reduce { _, action in
      switch action {
      case .onAppear:
        return .none

      case .kakaoLoginButtonClicked:
        return .run { send in
          let accessToken = try await fetchKakaoOAuthToken()
          _ = try await loginClient.login(loginType: .kakao,
                                              accessToken: accessToken)
        } catch: { error, send in
          debugPrint(error)
        }

      case .appleLoginButtonClicked(let token):
        return .run { send in
          _ = try await loginClient.login(loginType: .apple,
                                              accessToken: token)
        } catch: { error, send in
          debugPrint(error)
        }

      case .useAppAsNonMember:
        return .run { send in
          let response = try await loginClient.login(loginType: .anonymous,
                                                     accessToken: nil)
          KeychainManager.shared.addItem(key: "anonymousToken",
                                         value: response.accessToken)
        } catch: { error, send in
          debugPrint(error)
        }

      case .dismissLoginPage:
        return .none
      }
    }
  }

  private func fetchKakaoOAuthToken() async throws -> String {
    return try await withCheckedThrowingContinuation { continuation in
      let loginCompletion: (OAuthToken?, Error?) -> Void = { (oauthToken, error) in
        if let error = error {
          continuation.resume(throwing: error)
        } else {
          guard let accessToken = oauthToken?.accessToken else {
            continuation.resume(throwing: LoginError.emptyAccessToken)
            return
          }
          continuation.resume(returning: accessToken)
        }
      }

      DispatchQueue.main.async {
        if UserApi.isKakaoTalkLoginAvailable() {
          UserApi.shared.loginWithKakaoTalk(completion: loginCompletion)
        } else {
          UserApi.shared.loginWithKakaoAccount(completion: loginCompletion)
        }
      }
    }
  }
}
