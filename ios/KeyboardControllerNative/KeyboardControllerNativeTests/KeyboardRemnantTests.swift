import XCTest

final class KeyboardRemnantTests: XCTestCase {
  func testKeepsTrackedPositionWhenFrameSettlesAtBottom() {
    XCTAssertEqual(KeyboardRemnant.position(tracked: 120, start: 336, remnant: 0), 120)
  }

  func testKeepsTrackedPositionWhenFrameSettlesBelowBottom() {
    XCTAssertEqual(KeyboardRemnant.position(tracked: 120, start: 336, remnant: -20), 120)
  }

  func testKeepsTrackedPositionWhenRemnantIsNotBelowStart() {
    XCTAssertEqual(KeyboardRemnant.position(tracked: 40, start: 48, remnant: 48), 40)
    XCTAssertEqual(KeyboardRemnant.position(tracked: 40, start: 30, remnant: 48), 40)
  }

  func testStartsWhereTheHideStarts() {
    XCTAssertEqual(KeyboardRemnant.position(tracked: 336, start: 336, remnant: 48), 336)
  }

  func testReachesZeroWhereFrameSettlesOnRemnant() {
    XCTAssertEqual(KeyboardRemnant.position(tracked: 48, start: 336, remnant: 48), 0)
  }

  func testStaysAtZeroBelowRemnant() {
    XCTAssertEqual(KeyboardRemnant.position(tracked: 20, start: 336, remnant: 48), 0)
    XCTAssertEqual(KeyboardRemnant.position(tracked: 0, start: 336, remnant: 48), 0)
  }

  func testMapsTravelProportionally() {
    XCTAssertEqual(KeyboardRemnant.position(tracked: 192, start: 336, remnant: 48), 168)
    XCTAssertEqual(KeyboardRemnant.position(tracked: 120, start: 336, remnant: 48), 84)
  }

  func testFollowsTheWholeHideAlongTheSameCurve() {
    let start = 336.0
    let remnant = 48.0
    let curve = [1.0, 0.9, 0.62, 0.35, 0.14, 0.05, 0.01, 0.0]

    for fraction in curve {
      let tracked = remnant + (start - remnant) * fraction
      XCTAssertEqual(
        KeyboardRemnant.position(tracked: tracked, start: start, remnant: remnant),
        start * fraction,
        accuracy: 1e-9
      )
    }
  }

  func testFrameDestinationIsDistanceFromWindowBottom() {
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
    let view: UIView? = UIView(frame: CGRect(x: 0, y: 796, width: 390, height: 0))
    window.addSubview(view!)

    XCTAssertEqual(view.frameDestinationInWindow, 48)
  }

  func testFrameDestinationIsZeroAtWindowBottom() {
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
    let view: UIView? = UIView(frame: CGRect(x: 0, y: 844, width: 390, height: 0))
    window.addSubview(view!)

    XCTAssertEqual(view.frameDestinationInWindow, 0)
  }

  func testFrameDestinationReadsModelLayerDuringAnimation() {
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
    let view: UIView? = UIView(frame: CGRect(x: 0, y: 508, width: 390, height: 0))
    window.addSubview(view!)

    UIView.animate(withDuration: 10) {
      view!.frame.origin.y = 796
    }

    XCTAssertEqual(view.frameDestinationInWindow, 48)
  }

  func testFrameDestinationOfMissingViewIsZero() {
    let view: UIView? = nil

    XCTAssertEqual(view.frameDestinationInWindow, 0)
  }

  func testFrameDestinationOutsideWindowIsNotAboveBottom() {
    let view: UIView? = UIView(frame: CGRect(x: 0, y: 796, width: 390, height: 0))

    XCTAssertLessThanOrEqual(view.frameDestinationInWindow, 0)
  }
}
