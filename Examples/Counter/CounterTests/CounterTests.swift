//
//  CounterTests.swift
//  CounterTests
//
//  Created by Wellington Soares on 23/03/21.
//
import CombineBloc
import XCTest
@testable import Counter

class CounterTests: XCTestCase {

    func testInitialState(){
        let counterBloc = CounterBloc()
        XCTAssertEqual(counterBloc.state,CounterState(count:0))
    }

    func testIncrement(){
        let counterBloc = CounterBloc()
        counterBloc.send(.increment)
        XCTAssertEqual(counterBloc.state,CounterState(count:1))
        counterBloc.send(.increment)
        XCTAssertEqual(counterBloc.state,CounterState(count:2))
    }

    func testDecrement(){
        let counterBloc = CounterBloc()
        counterBloc.send(.decrement)
        XCTAssertEqual(counterBloc.state,CounterState(count:-1))
        counterBloc.send(.decrement)
        XCTAssertEqual(counterBloc.state,CounterState(count:-2))
    }
//
//
//
//
//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
