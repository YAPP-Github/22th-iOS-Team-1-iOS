//
//  MyPageView.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/26.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MyPageView: View {
  private let store: StoreOf<MyPage>

  init(store: StoreOf<MyPage>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store) { viewStore in
      mainView
        .onAppear {
          viewStore.send(.onAppear)
        }
    }
  }

  private var mainView: some View {
    WithViewStore(store) { viewStore in

      VStack(alignment: .leading, spacing: 0) {
        nickNameView
          .padding(.top, 110)

        if viewStore.loginType == .anonymous {
          Color.clear
            .frame(width: 0, height: 0)
            .padding(.top, 56)
        } else {
          linkedAccountTypeView
        }

        VStack(spacing: 0) {
          ForEach(viewStore.menuItems) { menuItem in
            menuItemView(menuItem: menuItem)
          }
        }
        .padding(.vertical, 10)

        Spacer()
      }
      .padding(.horizontal, 20)
    }
  }

  private var nickNameView: some View {
    WithViewStore(store) { viewStore in
      HStack {
        Text("닉네임")
          .applyCofficeFont(font: .header1)
          .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
        Spacer()
        Button {
          print("button")
        } label: {
          HStack(spacing: 0) {
            Text("SNS 로그인")
              .applyCofficeFont(font: .button)
            CofficeAsset.Asset.arrowDropRightLine24px.swiftUIImage
              .renderingMode(.template)
              .frame(width: 24, height: 24)
          }
          .tint(CofficeAsset.Colors.grayScale1.swiftUIColor)
          .padding(.vertical, 6)
          .padding(.leading, 16)
          .padding(.trailing, 2)
          .background(CofficeAsset.Colors.grayScale8.swiftUIColor)
          .cornerRadius(18)
        }
      }
    }
  }

  private var linkedAccountTypeView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        Divider()
        HStack(alignment: .center, spacing: 0) {
          Text("로그인")
            .applyCofficeFont(font: .header3)
            .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
            .frame(maxWidth: .infinity, alignment: .leading)

          HStack(spacing: 8) {
            viewStore.loginType.image
              .resizable()
              .frame(width: 18, height: 18)
            Text(viewStore.loginType.displayName)
              .applyCofficeFont(font: .body2Medium)
              .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
              .padding(.trailing, 10)
          }
        }
        .padding(.vertical, 29)
        Divider()
      }
      .padding(.top, 29)
    }
  }

  private func menuItemView(menuItem: MyPage.MenuItem) -> some View {
    WithViewStore(store) { viewStore in

      VStack(alignment: .leading, spacing: 0) {
        HStack {
          Button {
            viewStore.send(.menuButtonTapped(menuItem))
          } label: {
            Group {
              Text(menuItem.title)
                .applyCofficeFont(font: .header3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 50)
              if menuItem.menuType == .versionInformation {
                Text(viewStore.versionNumber)
                  .applyCofficeFont(font: .body1)
                  .tint(CofficeAsset.Colors.grayScale6.swiftUIColor)
              } else {
                CofficeAsset.Asset.arrowDropRightLine24px.swiftUIImage
                  .renderingMode(.template)
                  .frame(width: 24, height: 24)
              }
            }
            .tint(menuItem.textColor)
          }
        }
      }
    }
  }

  private var divider: some View {
    Divider()
      .frame(minHeight: 2)
      .overlay(Color.black)
  }
}

struct MyPageView_Previews: PreviewProvider {
  static var previews: some View {
    MyPageView(
      store: .init(
        initialState: .init(),
        reducer: MyPage()
      )
    )
  }
}
