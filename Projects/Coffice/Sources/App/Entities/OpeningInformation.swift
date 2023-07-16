//
//  OpeningInformation.swift
//  coffice
//
//  Created by 천수현 on 2023/07/09.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network

struct OpeningInformation: Hashable {
  let dayOpenInformations: [DayOpenInformation]
  var isOpened: Bool {
    let currentTime = Date.now
    let currentDateComponents = Calendar.current.dateComponents([.weekday, .hour, .minute], from: currentTime)
    let currentTimeValue = (currentDateComponents.hour ?? 0) * 60 + (currentDateComponents.minute ?? 0)

    guard let today = dayOpenInformations
      .first(where: { $0.weekDaySymbol.weekDayValue == currentDateComponents.weekday })
    else { return false }

    if is24Open { return true }

    let openTimeValue = today.openAt.hour * 60 + today.openAt.minute
    let closeTimeValue = today.closeAt.hour * 60 + today.closeAt.minute
    return openTimeValue < currentTimeValue && currentTimeValue < closeTimeValue
  }

  var is24Open: Bool {
    let today = todayInformation
    return today.openAt == today.closeAt
  }

  var formattedString: String {
    if is24Open {
      return "24시간"
    } else if isOpened {
      return "\(todayInformation.weekDaySymbol.rawValue) "
      + "\(todayInformation.openAt.hour)" + ":\(todayInformation.openAt.minute) "
      + "~ "
      + "\(todayInformation.openAt.hour)" + "\(todayInformation.closeAt.hour)"
    } else {
      return "영업종료"
    }
  }

  private var todayInformation: DayOpenInformation {
    let currentTime = Date.now
    let currentDateComponents = Calendar.current.dateComponents([.weekday, .hour, .minute], from: currentTime)
    guard let today = dayOpenInformations
      .first(where: { $0.weekDaySymbol.weekDayValue == currentDateComponents.weekday })
    else { return .init(weekDaySymbol: .monday, openAt: .dummy, closeAt: .dummy) }
    return today
  }
}

struct DayOpenInformation: Hashable {
  let weekDaySymbol: WeekDaySymbol
  let openAt: TimeInformation
  let closeAt: TimeInformation
}

struct TimeInformation: Hashable {
  static let dummy = TimeInformation(hour: 0, minute: 0)
  let hour: Int
  let minute: Int
}

enum WeekDaySymbol: String, Hashable {
  case sunday
  case monday
  case tuesday
  case wednesday
  case thursday
  case friday
  case saturday

  var weekDayValue: Int {
    switch self {
    case .sunday: return 0
    case .monday: return 1
    case .tuesday: return 2
    case .wednesday: return 3
    case .thursday: return 4
    case .friday: return 5
    case .saturday: return 6
    }
  }

  var weekDayString: String {
    switch self {
    case .sunday: return "일"
    case .monday: return "월"
    case .tuesday: return "화"
    case .wednesday: return "수"
    case .thursday: return "목"
    case .friday: return "금"
    case .saturday: return "토"
    }
  }

  static func symbol(of symbol: String?) -> WeekDaySymbol {
    guard let symbol else { return .monday }
    return WeekDaySymbol(rawValue: symbol.lowercased()) ?? .monday
  }
}

extension OpeningHourResponseDTO {
  func toEntity() -> DayOpenInformation {
    return .init(
      weekDaySymbol: WeekDaySymbol.symbol(of: dayOfWeek),
      openAt: openedAt?.toTimeInformation() ?? .dummy,
      closeAt: closedAt?.toTimeInformation() ?? .dummy
    )
  }
}

fileprivate extension String {
  func toTimeInformation() -> TimeInformation {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm+09:00"
    guard let date = dateFormatter.date(from: self)
    else { return .init(hour: 0, minute: 0) }
    let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
    return TimeInformation(hour: dateComponents.hour ?? 0, minute: dateComponents.minute ?? 0)
  }
}
