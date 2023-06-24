//
//  NaverMapView.swift
//  Cafe
//
//  Created by sehooon on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import SwiftUI
import NMapsMap
import ComposableArchitecture

struct NaverMapView: UIViewRepresentable {
  @ObservedObject var viewStore: ViewStoreOf<CafeMapCore>
  let view = NMFNaverMapView()

  func makeUIView(context: Context) -> NMFNaverMapView {
    setupMap(view)
    view.mapView.addCameraDelegate(delegate: context.coordinator)
    return view
  }

  func updateUIView(_ uiView: UIViewType, context: Context) {
    moveCameraToPoistion(viewStore.region, uiView)
    if viewStore.isCurrentButtonTapped {
      DispatchQueue.main.async { viewStore.send(.currentButtonToFalse) }
    }
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(target: self)
  }
}

// TODOs:
// [1] 화면 MaxZoom, MinZoom 정하기
// [2] 현재 cameraPosition에서 반경 계산
// [3] 카메라 이동 이벤트 추가
extension NaverMapView {
  func setupMap(_ view: NMFNaverMapView) {
    view.showScaleBar = false
    view.showZoomControls = false
    view.showLocationButton = false
    view.mapView.positionMode = .direction
    view.mapView.locationOverlay.hidden = false
    view.mapView.maxZoomLevel = 50
    view.mapView.minZoomLevel = 0
    moveCameraToPoistion(viewStore.region, view)
    addMarker(view)
  }

  func addMarker(_ view: NMFNaverMapView) {
    let marker = NMFMarker()
    marker.position = NMGLatLng(lat: 37.5819, lng: 127.0017)
    let controller = UIHostingController(rootView: MarkerView())
    controller.view.frame = CGRect(origin: .zero, size: CGSize(width: 240, height: 250))
    controller.view.backgroundColor = .clear
    let scenes = UIApplication.shared.connectedScenes
    let windowScene = scenes.first as? UIWindowScene
    let window = windowScene?.windows.first
    DispatchQueue.main.async {
      if let rootVC = window?.rootViewController {
        rootVC.view.insertSubview(controller.view, at: 0)
        let renderer  = UIGraphicsImageRenderer(size: CGSize(width: 240, height: 250))
        let markerImage = renderer.image { context in
          controller.view.layer.render(in: context.cgContext)
        }
        controller.view.removeFromSuperview()
        marker.iconImage = NMFOverlayImage(image: markerImage)
      }
    }
    marker.mapView = view.mapView
    marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
      moveCameraToPoistion(CLLocationCoordinate2D.init(latitude: 37.5819, longitude: 127.0017), view)
      return true
    }
  }

  func moveCameraToPoistion(_ coordinate: CLLocationCoordinate2D, _ view: NMFNaverMapView) {
    let latitude = coordinate.latitude
    let longitude = coordinate.longitude
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude, lng: longitude), zoomTo: 15)
    view.mapView.moveCamera(cameraUpdate)
  }
}

class Coordinator: NSObject, NMFMapViewCameraDelegate, NMFMapViewOptionDelegate {
  var target: NaverMapView

  init(target: NaverMapView) {
    self.target = target
  }
}