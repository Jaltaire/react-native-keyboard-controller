import Foundation

enum KeyboardRemnant {
  static func position(tracked: Double, start: Double, remnant: Double) -> Double {
    guard remnant > 0, start > remnant else {
      return tracked
    }

    return max(tracked - remnant, 0) / (start - remnant) * start
  }
}
