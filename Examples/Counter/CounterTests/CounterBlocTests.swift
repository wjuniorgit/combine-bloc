//
//  CounterTests.swift
//  CounterTests
//
//  Created by Wellington Soares on 23/03/21.
//
import Combine
import CombineBloc
@testable import Counter
import XCTest

class CounterBlocTests: XCTestCase {
  func testInitialState() {
    let counterBloc = CounterBloc()
    XCTAssertEqual(counterBloc.value, CounterState(count: 0))
  }

  func testIncrement() {
    let counterBloc = CounterBloc()
    Just(.increment).subscribe(counterBloc.subscriber)
    XCTAssertEqual(counterBloc.value, CounterState(count: 1))
    Just(.increment).subscribe(counterBloc.subscriber)
    XCTAssertEqual(counterBloc.value, CounterState(count: 2))
  }

  func testIncrementSequence() {
    let counterBloc = CounterBloc()
    [.increment, .increment, .increment, .increment].publisher
      .subscribe(counterBloc.subscriber)
    XCTAssertEqual(counterBloc.value, CounterState(count: 4))
    [.increment, .increment, .increment, .increment].publisher
      .subscribe(counterBloc.subscriber)
    XCTAssertEqual(counterBloc.value, CounterState(count: 8))
  }

  func testDecrementSequence() {
    let counterBloc = CounterBloc()
    [.decrement, .decrement, .decrement, .decrement].publisher
      .subscribe(counterBloc.subscriber)
    XCTAssertEqual(counterBloc.value, CounterState(count: -4))
    [.decrement, .decrement, .decrement, .decrement].publisher
      .subscribe(counterBloc.subscriber)
    XCTAssertEqual(counterBloc.value, CounterState(count: -8))
  }
}
