//
//  AuthenticationBlocTest.swift
//  LoginTests
//
//  Created by Wellington Soares on 06/04/21.
//

import Combine
import CombineBloc
@testable import Login
import XCTest

class AuthenticationBlocTests: XCTestCase {
  func testAuthenticationSuscess() {
    let authenticationBloc =
      AuthenticationBloc(repository: MockAuthRepository())

    let user = User(id: "123", name: "user")

    let predicate = NSPredicate { _, _ in
      authenticationBloc.value == .authenticated(user)
    }
    Just(.AuthenticationLoginRequested(username: "user", password: "pass"))
      .subscribe(authenticationBloc.subscriber)

    let expectation = XCTNSPredicateExpectation(
      predicate: predicate,
      object: authenticationBloc
    )
    let result = XCTWaiter().wait(for: [expectation], timeout: 2.1)
    switch result {
    default: XCTAssertEqual(authenticationBloc.value, .authenticated(user))
    }
  }

  func testAuthenticationError() {
    let authenticationBloc =
      AuthenticationBloc(repository: MockAuthRepository())

    let predicate = NSPredicate { _, _ in
      authenticationBloc
        .value == .unauthenticated(.incorrectCredentials("user", "word"))
    }
    Just(.AuthenticationLoginRequested(username: "user", password: "word"))
      .subscribe(authenticationBloc.subscriber)

    let expectation = XCTNSPredicateExpectation(
      predicate: predicate,
      object: authenticationBloc
    )
    let result = XCTWaiter().wait(for: [expectation], timeout: 2.1)
    switch result {
    default: XCTAssertEqual(
        authenticationBloc.value,
        .unauthenticated(.incorrectCredentials("user", "word"))
      )
    }
  }

  func testAuthenticating() {
    let authenticationBloc =
      AuthenticationBloc(repository: MockAuthRepository())
    Just(.AuthenticationLoginRequested(username: "user", password: "pass"))
      .subscribe(authenticationBloc.subscriber)
    XCTAssertEqual(
      authenticationBloc.value,
      .authenticating("user", "pass")
    )
  }
}
