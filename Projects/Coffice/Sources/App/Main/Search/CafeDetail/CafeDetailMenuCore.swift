//
//  CafeDetailMenuCore.swift
//  coffice
//
//  Created by Min Min on 2023/07/27.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct CafeDetailMenuReducer: ReducerProtocol {
  struct State: Equatable {
    @BindingState var cafeReviewWriteState: CafeReviewWrite.State?
    @BindingState var isReviewModifySheetPresented = false
    @BindingState var isReviewReportSheetPresented = false
    @BindingState var isReviewDeleteConfirmSheetPresented = false
    @BindingState var deleteConfirmBottomSheetState: BottomSheetReducer.State?
    @BindingState var webViewState: CommonWebReducer.State?

    let userReviewEmptyDescription = """
                                     아직 리뷰가 없어요!
                                     첫 리뷰를 작성해볼까요?
                                     """
    let reviewUploadFinishedMessage = "리뷰가 등록되었습니다."
    let reviewEditFinishedMessage = "리뷰가 수정되었습니다."
    let reviewDeleteFinishedMessage = "리뷰가 삭제되었습니다."
    let reviewReportFinishedMessage = "신고가 접수되었습니다."
    var hasNextReview: Bool?
    var lastReviewDistance: Double = .zero
    var reviewPageSize: Int = 10

    var cafe: Cafe?
    var user: User?
    var needToPresentRunningTimeDetailInfo = false
    var userReviewCellViewStates: [UserReviewCellViewState] = []
    var selectedUserReviewCellViewState: UserReviewCellViewState?
    var selectedReviewSheetActionType: ReviewSheetButtonActionType = .none
    var subMenuViewStates: [SubMenusViewState] = SubMenuType.allCases
      .map { SubMenusViewState.init(subMenuType: $0, isSelected: $0 == .detailInfo) }
    var bottomSheetType: BottomSheetType = .deleteConfirm
    let subMenuTypes = SubMenuType.allCases

    var selectedSubMenuType: SubMenuType = .detailInfo {
      didSet {
        subMenuViewStates = SubMenuType.allCases.map { subMenuType in
          SubMenusViewState(
            subMenuType: subMenuType,
            isSelected: subMenuType == selectedSubMenuType
          )
        }
      }
    }

    mutating func update(cafe: Cafe?) -> EffectTask<Action> {
      self.cafe = cafe
      return EffectTask(value: .fetchReviews)
    }
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case onAppear
    case subMenuTapped(State.SubMenuType)
    case reviewWriteButtonTapped
    case updateReviewCellViewStates(response: ReviewsResponse)
    case toggleToPresentRunningTime
    case cafeHomepageUrlTapped
    case fetchUserData
    case fetchUserDataResponse(TaskResult<User>)
    case delegate(Delegate)

    // MARK: Web View
    case commonWebReducerAction(CommonWebReducer.Action)
    case dismissWebView

    // MARK: User Review
    case cafeReviewWrite(action: CafeReviewWrite.Action)
    case bottomSheet(action: BottomSheetReducer.Action)
    case fetchReviews
    case fetchReviewsResponse(TaskResult<ReviewsResponse>)
    case reportReview
    case reportReviewResponse(TaskResult<HTTPURLResponse>)
    case deleteReview
    case deleteReviewResponse(TaskResult<HTTPURLResponse>)
    case reviewModifyButtonTapped(viewState: State.UserReviewCellViewState)
    case reviewModifySheetDismissed
    case reviewEditSheetButtonTapped
    case reviewDeleteSheetButtonTapped
    case reviewReportSheetButtonTapped
    case reviewReportButtonTapped(viewState: State.UserReviewCellViewState)
    case presentCafeReviewWriteView(CafeReviewWrite.State)
    case resetSelectedReviewModifySheetActionType

    case reviewDeleteConfirmSheet(isPresented: Bool)
    case reviewReportSheet(isPresented: Bool)
    case reviewModifySheet(isPresented: Bool)
    case reviewDeleteConfirmBottomSheet(isPresented: Bool)
  }

  enum Delegate: Equatable {
    case presentToastView(message: String)
  }

  @Dependency(\.reviewAPIClient) private var reviewAPIClient
  @Dependency(\.accountClient) private var accountClient

  var body: some ReducerProtocolOf<Self> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .onAppear:
        return EffectTask(value: .fetchUserData)

      case .subMenuTapped(let menuType):
        state.selectedSubMenuType = menuType
        return .none

      case .toggleToPresentRunningTime:
        state.needToPresentRunningTimeDetailInfo.toggle()
        return .none

      case .cafeHomepageUrlTapped:
        guard let webViewUrlString = state.cafe?.homepageUrl
        else { return .none }

        state.webViewState = .init(urlString: webViewUrlString)
        return .none

      case .dismissWebView:
        state.webViewState = nil
        return .none

      case .fetchUserData:
        return .run { send in
          let user = try await accountClient.fetchUserData()
          await send(.fetchUserDataResponse(.success(user)))
        } catch: { error, send in
          await send(.fetchUserDataResponse(.failure(error)))
        }

      case .fetchUserDataResponse(let result):
        switch result {
        case .success(let user):
          state.user = user
        case .failure(let error):
          debugPrint(error.localizedDescription)
        }
        return .none

      default:
        return .none
      }
    }
    .ifLet(
      \.webViewState,
      action: /Action.commonWebReducerAction
    ) {
      CommonWebReducer()
    }

    // MARK: - Review
    Reduce { state, action in
      switch action {
      case .updateReviewCellViewStates(let reviewsResponse):
        state.hasNextReview = reviewsResponse.hasNext
        state.userReviewCellViewStates = reviewsResponse.reviews
          .compactMap { [userId = state.user?.id] review in
            return .init(
              reviewId: review.reviewId,
              memberId: review.memberId,
              userName: review.memberName,
              date: review.createdDate,
              content: review.content,
              tagTypes: [
                review.outletOption == .enough ? .enoughOutlets : nil,
                review.wifiOption == .fast ? .fastWifi : nil,
                review.noiseOption == .quiet ? .quiet : nil
              ]
                .compactMap { $0 },
              isMyReview: review.memberId == userId,
              outletOption: review.outletOption,
              wifiOption: review.wifiOption,
              noiseOption: review.noiseOption
            )
          }
        return .none

      case .fetchReviews:
        guard let placeId = state.cafe?.placeId
        else { return .none }

        return .run { send in
          let reviewsResponse = try await reviewAPIClient.fetchReviews(requestValue: .init(placeId: placeId))
          await send(.fetchReviewsResponse(.success(reviewsResponse)))
        } catch: { error, send in
          await send(.fetchReviewsResponse(.failure(error)))
        }

      case .reportReview:
        guard let reviewId = state.selectedUserReviewCellViewState?.reviewId,
              let placeId = state.cafe?.placeId
        else { return .none }

        return .run { send in
          let response = try await reviewAPIClient.reportReview(placeId: placeId, reviewId: reviewId)
          await send(.reportReviewResponse(.success(response)))
        } catch: { error, send in
          await send(.reportReviewResponse(.failure(error)))
        }

      case .deleteReview:
        guard let reviewId = state.selectedUserReviewCellViewState?.reviewId,
              let placeId = state.cafe?.placeId
        else { return .none }

        return .run { send in
          let response = try await reviewAPIClient.deleteReview(placeId: placeId, reviewId: reviewId)
          await send(.deleteReviewResponse(.success(response)))
        } catch: { error, send in
          await send(.deleteReviewResponse(.failure(error)))
        }

      case .fetchReviewsResponse(let result):
        switch result {
        case .success(let reviewsResponse):
          return EffectTask(value: .updateReviewCellViewStates(response: reviewsResponse))
        case .failure(let error):
          debugPrint(error.localizedDescription)
        }
        return .none

      case .reportReviewResponse(let result):
        switch result {
        case .success:
          return EffectTask(value: .delegate(.presentToastView(message: state.reviewReportFinishedMessage)))
        case .failure(let error):
          debugPrint(error.localizedDescription)
        }
        return .none

      case .deleteReviewResponse(let result):
        switch result {
        case .success:
          return .merge(
            EffectTask(value: .delegate(.presentToastView(message: state.reviewDeleteFinishedMessage))),
            EffectTask(value: .fetchReviews)
          )
        case .failure(let error):
          debugPrint(error.localizedDescription)
        }
        return .none

      case .reviewWriteButtonTapped:
        guard let placeId = state.cafe?.placeId
        else { return .none }

        return EffectTask(
          value: .presentCafeReviewWriteView(
            .init(
              reviewType: .create,
              placeId: placeId,
              imageUrlString: state.cafe?.imageUrls?.first,
              cafeName: state.cafe?.name,
              cafeAddress: state.cafe?.address?.address
            )
          )
        )

      case .presentCafeReviewWriteView(let viewState):
        state.cafeReviewWriteState = viewState
        return .none

      case .cafeReviewWrite(let action):
        switch action {
        case .uploadReviewResponse(.success):
          return .merge(
            EffectTask(value: .delegate(.presentToastView(message: state.reviewUploadFinishedMessage))),
            EffectTask(value: .fetchReviews)
          )
        case .editReviewResponse(.success):
          return .merge(
            EffectTask(value: .delegate(.presentToastView(message: state.reviewEditFinishedMessage))),
            EffectTask(value: .fetchReviews)
          )
        case .dismissView:
          state.cafeReviewWriteState = nil
        default:
          return .none
        }
        return .none

      case .reviewModifySheetDismissed:
        guard let cellViewState = state.selectedUserReviewCellViewState,
              let placeId = state.cafe?.placeId
        else { return .none }

        var popActionEffectTask: EffectTask<Action> = .none

        switch state.selectedReviewSheetActionType {
        case .edit:
          popActionEffectTask = EffectTask(
            value: .presentCafeReviewWriteView(
              .init(
                reviewType: .edit,
                placeId: placeId,
                imageUrlString: state.cafe?.imageUrls?.first,
                reviewId: cellViewState.reviewId,
                cafeName: state.cafe?.name,
                cafeAddress: state.cafe?.address?.address,
                outletOption: cellViewState.outletOption,
                wifiOption: cellViewState.wifiOption,
                noiseOption: cellViewState.noiseOption,
                reviewText: cellViewState.content
              )
            )
          )
          .delay(for: 0.1, scheduler: DispatchQueue.main)
          .eraseToEffect()
        case .delete:
          return EffectTask(value: .reviewDeleteConfirmBottomSheet(isPresented: true))
            .delay(for: 0.1, scheduler: DispatchQueue.main)
            .eraseToEffect()
        default:
          return .none
        }

        return .merge(
          popActionEffectTask,
          EffectTask(value: .resetSelectedReviewModifySheetActionType)
        )

      case .reviewModifySheet(let isPresented):
        state.isReviewModifySheetPresented = isPresented
        return .none

      case .reviewReportSheet(let isPresented):
        state.isReviewReportSheetPresented = isPresented
        return .none

      case .reviewDeleteConfirmSheet(let isPresented):
        state.isReviewDeleteConfirmSheetPresented = isPresented
        return .none

      case .reviewDeleteConfirmBottomSheet(let isPresented):
        if isPresented {
          state.deleteConfirmBottomSheetState = .init()
        } else {
          state.deleteConfirmBottomSheetState = nil
        }
        return .none

      case .reviewModifyButtonTapped(let viewState):
        state.selectedUserReviewCellViewState = viewState
        return EffectTask(value: .reviewModifySheet(isPresented: true))

      case .reviewEditSheetButtonTapped:
        state.selectedReviewSheetActionType = .edit
        return EffectTask(value: .reviewModifySheet(isPresented: false))

      case .reviewDeleteSheetButtonTapped:
        state.selectedReviewSheetActionType = .delete
        return EffectTask(value: .reviewModifySheet(isPresented: false))

      case .reviewReportSheetButtonTapped:
        state.selectedReviewSheetActionType = .report
        return .merge(
          EffectTask(value: .reviewReportSheet(isPresented: false)),
          EffectTask(value: .reportReview)
        )

      case .reviewReportButtonTapped(let viewState):
        state.selectedUserReviewCellViewState = viewState
        return EffectTask(value: .reviewReportSheet(isPresented: true))

      case .bottomSheet(let action):
        switch action {
        case .confirmButtonTapped:
          return .merge(
            EffectTask(value: .deleteReview),
            EffectTask(value: .reviewDeleteConfirmBottomSheet(isPresented: false))
          )
        case .cancelButtonTapped:
          return EffectTask(value: .reviewDeleteConfirmBottomSheet(isPresented: false))
        }

      case .resetSelectedReviewModifySheetActionType:
        state.selectedReviewSheetActionType = .none
        return .none

      default:
        return .none
      }
    }
    .ifLet(
      \.cafeReviewWriteState,
      action: /Action.cafeReviewWrite(action:)
    ) {
      CafeReviewWrite()
    }
  }
}

extension CafeDetailMenuReducer {
  enum BottomSheetType {
    case deleteConfirm

    var content: BottomSheetContent {
      switch self {
      case .deleteConfirm:
        return .init(
          title: "정말로 삭제하시나요?",
          description: "삭제한 내용은 다시 되돌릴 수 없어요!",
          confirmButtonTitle: "삭제하기",
          cancelButtonTitle: "취소하기"
        )
      }
    }
  }
}

extension CafeDetailMenuReducer.State {
  var userReviewHeaderTitle: String {
    return "리뷰 \(userReviewCellViewStates.count)"
  }

  var cafeName: String {
    cafe?.name ?? "-"
  }

  var runningTimeDetailInfoArrowImageName: String {
    return needToPresentRunningTimeDetailInfo
    ? CofficeAsset.Asset.arrowDropUpLine24px.name
    : CofficeAsset.Asset.arrowDropDownLine24px.name
  }
}

extension CafeDetailMenuReducer.State {
  enum SubMenuType: CaseIterable {
    case detailInfo
    case review
  }

  struct SubMenusViewState: Identifiable, Equatable {
    let id = UUID()
    let type: SubMenuType
    let isSelected: Bool
    var foregroundColorAsset: CofficeColors {
      isSelected ? CofficeAsset.Colors.grayScale9 : CofficeAsset.Colors.grayScale5
    }

    var bottomBorderColorAsset: CofficeColors {
      isSelected ? CofficeAsset.Colors.grayScale9 : CofficeAsset.Colors.grayScale1
    }

    init(subMenuType: SubMenuType, isSelected: Bool = false) {
      self.type = subMenuType
      self.isSelected = isSelected
    }

    var title: String {
      switch type {
      case .detailInfo: return "세부정보"
      case .review: return "리뷰"
      }
    }
  }
}

// MARK: - Review

extension CafeDetailMenuReducer.State {
  struct UserReviewCellViewState: Hashable, Identifiable {
    let id = UUID()
    let reviewId: Int
    let memberId: Int
    let userName: String
    let date: Date?
    let content: String
    let tagTypes: [ReviewTagType]
    let isMyReview: Bool
    let outletOption: ReviewOption.OutletOption
    let wifiOption: ReviewOption.WifiOption
    let noiseOption: ReviewOption.NoiseOption

    var dateDescription: String {
      guard let date else { return "-" }

      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "ko_KR")
      dateFormatter.dateFormat = "M.dd E"
      return dateFormatter.string(from: date)
    }
  }

  enum ReviewTagType: CaseIterable {
    case enoughOutlets
    case fastWifi
    case quiet

    var title: String {
      switch self {
      case .enoughOutlets:
        return "🔌 콘센트 넉넉해요"
      case .fastWifi:
        return "📶 와이파이 빨라요"
      case .quiet:
        return "🔊 조용해요"
      }
    }
  }

  enum ReviewSheetButtonActionType {
    case edit
    case delete
    case report
    case none
  }
}
