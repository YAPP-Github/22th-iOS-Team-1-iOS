//
//  MainCoordinatorCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/26.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

// MARK: - MainCoordniatorCore

struct MainCoordinator: ReducerProtocol {
  struct State: Equatable {
    static let initialState = MainCoordinator.State(
      homeState: .initialState,
      searchState: .initialState,
      savedListState: .initialState,
      myPageState: .initialState,
      tabBarState: .init()
    )

    var homeState: HomeCoordinator.State
    var searchState: SearchCoordinator.State
    var savedListState: SavedListCoordinator.State
    var myPageState: MyPageCoordinator.State
    var tabBarState: TabBar.State

    var filterSheetState: CafeFilterBottomSheet.State?
    var commonBottomSheetState: CommonBottomSheet.State?
    var bubbleMessageState: BubbleMessage.State?

    var shouldShowTabBarView = true
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case home(HomeCoordinator.Action)
    case search(SearchCoordinator.Action)
    case savedList(SavedListCoordinator.Action)
    case myPage(MyPageCoordinator.Action)
    case tabBar(TabBar.Action)
    case filterBottomSheet(action: CafeFilterBottomSheet.Action)
    case commonBottomSheet(action: CommonBottomSheet.Action)
    case bubbleMessage(BubbleMessage.Action)
    case dismissToastMessageView
    case dismissBubbleMessageView
    case onAppear
  }

  var body: some ReducerProtocolOf<MainCoordinator> {
    BindingReducer()
    Scope(state: \State.homeState, action: /Action.home) {
      HomeCoordinator()
    }

    Scope(state: \State.searchState, action: /Action.search) {
      SearchCoordinator()
    }

    Scope(state: \State.savedListState, action: /Action.savedList) {
      SavedListCoordinator()
    }

    Scope(state: \State.myPageState, action: /Action.myPage) {
      MyPageCoordinator()
    }

    Scope(state: \State.tabBarState, action: /Action.tabBar) {
      TabBar()
    }

    Reduce { state, action in
      switch action {
      case .filterBottomSheet(.dismiss):
        state.shouldShowTabBarView = true
        state.filterSheetState = nil
        return .none

      case .filterBottomSheet(.saveCafeFilter(let information)):
        return EffectTask(
          value: .search(
            .routeAction(0, action: .cafeMap(.updateCafeFilter(information: information)))
          )
        )

      case .filterBottomSheet(.dismissWithDelay):
        return .merge(
          EffectTask(value: .search(.routeAction(
            0,
            action: .cafeMap(.filterBottomSheetDismissed)
          ))),
          EffectTask(value: .search(.routeAction(
            0,
            action: .cafeMap(.cafeSearchListAction(.filterBottomSheetDismissed))
          )))
        )

      case .commonBottomSheet(.dismiss):
        state.commonBottomSheetState = nil
        return .none

      case .onAppear:
        return .none

      case .tabBar(.selectTab(let itemType)):
        debugPrint("selectedTab : \(itemType)")
        return .none

      case
          .search(.routeAction(_, .cafeMap(.cafeFilterMenus(
            action: .presentFilterBottomSheetView(let filterSheetState)
          )))),
          .search(.routeAction(_, .cafeMap(.cafeSearchListAction(.cafeFilterMenus(
            action: .presentFilterBottomSheetView(let filterSheetState)
          ))))):
        state.shouldShowTabBarView = false
        state.filterSheetState = filterSheetState
        return .none

      case .search(.routeAction(_, .cafeSearchDetail(.presentBubbleMessageView(let bubbleMessageState)))),
          .filterBottomSheet(.presentBubbleMessageView(let bubbleMessageState)):
        state.shouldShowTabBarView = false
        state.bubbleMessageState = bubbleMessageState
        return .none

      case .dismissBubbleMessageView:
        state.shouldShowTabBarView = true
        state.bubbleMessageState = nil
        return .none

      case .myPage(.routeAction(_, .editProfile(.hideTabBar))):
        state.shouldShowTabBarView = false
        return .none

      case .myPage(.routeAction(_, .editProfile(.showTabBar))):
        state.shouldShowTabBarView = true
        return .none

      default:
        return .none
      }
    }
    .ifLet(
      \.filterSheetState,
      action: /Action.filterBottomSheet
    ) {
      CafeFilterBottomSheet()
    }
    .ifLet(
      \.commonBottomSheetState,
      action: /Action.commonBottomSheet
    ) {
      CommonBottomSheet()
    }
  }
}
