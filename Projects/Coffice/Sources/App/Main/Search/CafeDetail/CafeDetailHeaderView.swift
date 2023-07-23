//
//  CafeSearchDetailHeaderView.swift
//  coffice
//
//  Created by Min Min on 2023/06/26.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Kingfisher
import SwiftUI

struct CafeDetailHeaderView: View {
  private let store: StoreOf<CafeDetail>

  init(store: StoreOf<CafeDetail>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        imagePageView

        VStack(spacing: 0) {
          HStack {
            VStack(spacing: 0) {
              Text("카페")
                .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                .applyCofficeFont(font: .button)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 20)
              Text(viewStore.cafeName)
                .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                .applyCofficeFont(font: .header0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 36)
                .padding(.top, 8)
              Text(viewStore.cafeAddress)
                .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                .applyCofficeFont(font: .body1Medium)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 20)
                .padding(.top, 4)
            }

            VStack {
              Button {
                viewStore.send(.bookmarkButtonTapped)
              } label: {
                viewStore.bookmarkButtonImage.swiftUIImage
              }
              Spacer()
            }
          }

          HStack(spacing: 8) {
            Text(viewStore.openingStateDescription)
              .foregroundColor(CofficeAsset.Colors.secondary1.swiftUIColor)
              .applyCofficeFont(font: .button)
              .frame(alignment: .leading)
            Text(viewStore.todayRunningTimeDescription)
              .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
              .applyCofficeFont(font: .body1Medium)
            Spacer()
          }
          .padding(.top, 16)

          CofficeAsset.Colors.grayScale3.swiftUIColor
            .frame(height: 1)
            .padding(.top, 21)
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 16, trailing: 20))
      }
    }
  }

  var imagePageView: some View {
    WithViewStore(store) { viewStore in
      Group {
        if let imageUrls = viewStore.cafe?.imageUrls,
           imageUrls.isNotEmpty {
          TabView {
            ForEach(imageUrls, id: \.self) { imageUrl in
              KFImage.url(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
            }
          }
          .tabViewStyle(PageTabViewStyle())
        } else {
          LinearGradient(
            gradient: Gradient(colors: [.black.opacity(0.06), .black.opacity(0.3)]),
            startPoint: .top,
            endPoint: .bottom
          )
          .background(
            CofficeAsset.Asset.cafePlaceholder.swiftUIImage
              .resizable()
              .scaledToFill()
              .padding(.top, UIApplication.keyWindow?.safeAreaInsets.top ?? 0.0)
          )
        }
      }
      .frame(height: viewStore.imagePageViewHeight)
    }
  }
}

struct CafeDetailHeaderView_Previews: PreviewProvider {
  static var previews: some View {
    CafeDetailHeaderView(
      store: .init(
        initialState: .init(cafeId: 21),
        reducer: CafeDetail()
      )
    )
  }
}
