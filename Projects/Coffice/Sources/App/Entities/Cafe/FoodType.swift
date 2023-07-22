//
//  FoodType.swift
//  coffice
//
//  Created by 천수현 on 2023/07/22.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

enum FoodType: Hashable {
  case glutenFree
  case mealWorthy

  static func type(of foodType: String) -> FoodType? {
    switch foodType {
    case "GLUTEN_FREE": return .glutenFree
    case "MEAL_WORTHY": return .mealWorthy
    default: return nil
    }
  }

  var dtoName: String {
    switch self {
    case .glutenFree: return "GLUTEN_FREE"
    case .mealWorthy: return "MEAL_WORTHY"
    }
  }
}