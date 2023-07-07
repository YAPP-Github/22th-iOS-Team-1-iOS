//
//  EditProfileView.swift
//  coffice
//
//  Created by 천수현 on 2023/07/07.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct EditProfileView: View {
  private let store: StoreOf<EditProfile>

  init(store: StoreOf<EditProfile>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store) { viewStore in
      nickNameView
        .customNavigationBar(
          centerView: {
            Text("프로필 편집")
              .applyCofficeFont(font: .subtitleSemiBold)
              .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
          },
          leftView: {
            EmptyView()
          },
          rightView: {
            Button {
              viewStore.send(.dismissButtonTapped)
            } label: {
              CofficeAsset.Asset.close40px.swiftUIImage
                .frame(width: 40, height: 40)
            }
          }
        )
        .onAppear {
          viewStore.send(.hideTabBar)
        }
    }
  }

  private var nickNameView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 24) {
        Spacer()
        Text("닉네임")
          .applyCofficeFont(font: .header3)
          .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.leading, 20)

        ZStack {
          RoundedRectangle(cornerRadius: 8)
            .stroke(CofficeAsset.Colors.grayScale3.swiftUIColor,
                    lineWidth: 1)
          HStack {

            TextField("지하철, 카페 이름으로 검색",
                      text: viewStore.binding(\.$nicknameTextField))
            .applyCofficeFontForTextField(font: .subtitle1Medium)
            .keyboardType(.default)
            .textFieldStyle(.plain)
            .padding(20)
            .tint(CofficeAsset.Colors.grayScale9.swiftUIColor)

            if viewStore.nicknameTextField.isNotEmpty {
              Button {
                viewStore.send(.clearText)
              } label: {
                CofficeAsset.Asset.closeCircleFill18px.swiftUIImage
                  .resizable()
                  .renderingMode(.template)
                  .frame(width: 18, height: 18)
                  .scaledToFit()
                  .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
              }
              .padding(.trailing, 8)
            } else {
              Color.clear
                .frame(width: 24, height: 24)
                .padding(.trailing, 8)
            }
          }
        }
        .frame(height: 60)
        .padding(.horizontal, 20)

        Spacer()

        Button {
          viewStore.send(.confirmButtonTapped)
        } label: {
          Text("완료")
            .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale1))
            .applyCofficeFont(font: .button)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .background(
          viewStore.isNicknameValid
          ? CofficeAsset.Colors.grayScale9.swiftUIColor
          : CofficeAsset.Colors.grayScale5.swiftUIColor
        )
        .cornerRadius(4)
        .padding(.horizontal, 20)
        .disabled(viewStore.isNicknameValid.isFalse)
      }
    }
  }
}

struct EditProfileView_Previews: PreviewProvider {
  static var previews: some View {
    EditProfileView(
      store: .init(
        initialState: .init(),
        reducer: EditProfile()
      )
    )
  }
}
