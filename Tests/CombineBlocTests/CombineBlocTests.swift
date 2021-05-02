import Combine
@testable import CombineBloc
import XCTest

final class CombineBlocTests: XCTestCase {
  enum TestEvent: Equatable {
    case toFirstState
    case toSecondState
    case toThirdState
  }

  enum TestState: Equatable {
    case FirstState
    case SecondState
    case ThirdState
  }

  final class TestBloc: Bloc<TestEvent, TestState> {
    init() {
      super.init(initialValue: .FirstState) {
        event, _, emit in
        switch event {
        case .toFirstState:
          emit(.FirstState)
        case .toSecondState:
          emit(.SecondState)
        case .toThirdState:
          emit(.ThirdState)
        }
      }
    }
  }

  func testInitialState() {
    let testBloc = TestBloc()
    XCTAssertEqual(testBloc.value, TestState.FirstState)
  }

  func testMapEventToState() {
    let testBloc = TestBloc()
    XCTAssertEqual(testBloc.value, TestState.FirstState)
    testBloc.send(.toSecondState)
    XCTAssertEqual(testBloc.value, TestState.SecondState)
    testBloc.send(.toThirdState)
    XCTAssertEqual(testBloc.value, TestState.ThirdState)
    testBloc.send(.toFirstState)
    XCTAssertEqual(testBloc.value, TestState.FirstState)
  }

  func testSend() {
    let testBloc = TestBloc()
    XCTAssertEqual(testBloc.value, TestState.FirstState)
    testBloc.send(.toSecondState)
    XCTAssertEqual(testBloc.value, TestState.SecondState)
    testBloc.send(.toThirdState)
    XCTAssertEqual(testBloc.value, TestState.ThirdState)
    testBloc.send(.toFirstState)
    XCTAssertEqual(testBloc.value, TestState.FirstState)
  }

  func testSubscriber() {
    let testBloc = TestBloc()
    XCTAssertEqual(testBloc.value, TestState.FirstState)
    Just(.toSecondState).subscribe(testBloc.subscriber)
    XCTAssertEqual(testBloc.value, TestState.SecondState)
    Just(.toThirdState).subscribe(testBloc.subscriber)
    XCTAssertEqual(testBloc.value, TestState.ThirdState)
    Just(.toFirstState).subscribe(testBloc.subscriber)
    XCTAssertEqual(testBloc.value, TestState.FirstState)
  }

  func testSubscriberSequence() {
    let testBloc = TestBloc()
    XCTAssertEqual(testBloc.value, TestState.FirstState)
    [.toSecondState, .toThirdState].publisher.subscribe(testBloc.subscriber)
    XCTAssertEqual(testBloc.value, TestState.ThirdState)
  }

  func testCance() {
    let testBloc = TestBloc()
    XCTAssertEqual(testBloc.value, TestState.FirstState)
    testBloc.cancel()
    Just(.toSecondState).subscribe(testBloc.subscriber)
    XCTAssertEqual(testBloc.value, TestState.FirstState)
    testBloc.send(.toThirdState)
    XCTAssertEqual(testBloc.value, TestState.FirstState)
  }

  static var allTests = [
    ("testInitialState", testInitialState),
    ("testMapEventToState", testMapEventToState),
    ("testSend", testSend),
    ("testSubscriber", testSubscriber),
    ("testSubscriberSequence", testSubscriberSequence),
    ("testCance", testCance)
  ]
}
