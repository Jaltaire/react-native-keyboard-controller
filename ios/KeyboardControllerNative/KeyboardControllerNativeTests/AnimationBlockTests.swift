import XCTest

final class AnimationBlockTests: XCTestCase {
  private var guide: UIView!
  private var observation: NSKeyValueObservation?
  private var tracked: [CGFloat] = []

  override func setUp() {
    super.setUp()
    guide = UIView(frame: CGRect(x: 0, y: 563, width: 430, height: 0))
    tracked = []
    observation = guide.observe(\.center, options: .new) { [unowned self] _, change in
      guard let center = change.newValue, !UIView.isInsideAnimationBlock else {
        return
      }
      self.tracked.append(center.y)
    }
  }

  override func tearDown() {
    observation?.invalidate()
    observation = nil
    guide = nil
    super.tearDown()
  }

  func testIsNotInsideOutsideAnimationBlock() {
    XCTAssertFalse(UIView.isInsideAnimationBlock)
  }

  func testIsInsideAnimationBlock() {
    var inside = false

    UIView.animate(withDuration: 0.25) {
      inside = UIView.isInsideAnimationBlock
    }

    XCTAssertTrue(inside)
  }

  func testIsInsideSpringAnimationBlock() {
    var inside = false

    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0,
      options: []
    ) {
      inside = UIView.isInsideAnimationBlock
    }

    XCTAssertTrue(inside)
  }

  func testIsNotInsideWithoutAnimation() {
    var inside = true

    UIView.performWithoutAnimation {
      inside = UIView.isInsideAnimationBlock
    }

    XCTAssertFalse(inside)
  }

  func testIgnoresGuideMoveInsideAnimationBlock() {
    UIView.animate(withDuration: 0.38) {
      self.guide.center = CGPoint(x: 215, y: 884)
    }

    XCTAssertEqual(tracked, [])
  }

  func testTracksDragOutsideAnimationBlock() {
    guide.center = CGPoint(x: 215, y: 700)
    guide.center = CGPoint(x: 215, y: 760)

    XCTAssertEqual(tracked, [700, 760])
  }

  func testTracksDragAfterAnimatedMove() {
    UIView.animate(withDuration: 0.38) {
      self.guide.center = CGPoint(x: 215, y: 884)
    }
    guide.center = CGPoint(x: 215, y: 600)

    XCTAssertEqual(tracked, [600])
  }
}
