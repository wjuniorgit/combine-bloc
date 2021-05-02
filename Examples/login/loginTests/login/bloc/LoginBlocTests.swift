//
//  LoginBlocTests.swift
//  LoginTests
//
//  Created by Wellington Soares on 06/04/21.
//

import Combine
import CombineBloc
@testable import Login
import XCTest

class LoginBlocTests: XCTestCase {
  func testAuthenticatedInitialState() {
    let loginBloc = LoginBloc(
      authenticationState: .authenticated(User(id: "123", name: "user")),
      onLoginRequested: { _, _ in
      }
    )
    XCTAssertEqual(
      loginBloc.value,
      LoginState(
        userName: "",
        password: "",
        loginFormState: LoginFormState.clean
      )
    )
  }

  func testUnauthenticatedInitialState() {
    let loginBloc = LoginBloc(
      authenticationState: .unauthenticated(.unauthenticated),
      onLoginRequested: { _, _ in
      }
    )
    XCTAssertEqual(
      loginBloc.value,
      LoginState(
        userName: "",
        password: "",
        loginFormState: LoginFormState.clean
      )
    )
  }

  func testIncorrectCredentialsInitialState() {
    let loginBloc = LoginBloc(
      authenticationState: .unauthenticated(.incorrectCredentials(
        "user",
        "word"
      )),
      onLoginRequested: { _, _ in
      }
    )
    XCTAssertEqual(
      loginBloc.value,
      LoginState(
        userName: "user",
        password: "word",
        loginFormState: LoginFormState.retry
      )
    )
  }

  func testAuthenticatingCredentialsInitialState() {
    let loginBloc = LoginBloc(
      authenticationState: .authenticating("user", "pass"),
      onLoginRequested: { _, _ in
      }
    )
    XCTAssertEqual(
      loginBloc.value,
      LoginState(
        userName: "user",
        password: "pass",
        loginFormState: LoginFormState.submitting
      )
    )
  }

  func testUnknownInitialState() {
    let loginBloc = LoginBloc(
      authenticationState: .unknown,
      onLoginRequested: { _, _ in
      }
    )
    XCTAssertEqual(
      loginBloc.value,
      LoginState(
        userName: "",
        password: "",
        loginFormState: LoginFormState.clean
      )
    )
  }

  func testLoginUsernameChanged() {
    let loginBloc = LoginBloc(
      authenticationState: .unauthenticated(.unauthenticated),
      onLoginRequested: { _, _ in
      }
    )
    Just(LoginEvent.loginUsernameChanged("user"))
      .subscribe(loginBloc.subscriber)
    XCTAssertEqual(
      loginBloc.value,
      LoginState(
        userName: "user",
        password: "",
        loginFormState: LoginFormState.clean
      )
    )
  }

  func testLoginPasswordChanged() {
    let loginBloc = LoginBloc(
      authenticationState: .unauthenticated(.unauthenticated),
      onLoginRequested: { _, _ in
      }
    )
    Just(LoginEvent.loginPasswordChanged("pass"))
      .subscribe(loginBloc.subscriber)
    XCTAssertEqual(
      loginBloc.value,
      LoginState(
        userName: "",
        password: "pass",
        loginFormState: LoginFormState.clean
      )
    )
  }

  func testTryLogin() {
    let expectation =
      XCTestExpectation(description: "onLoginRequested was called")

    let loginBloc = LoginBloc(
      authenticationState: .unauthenticated(.unauthenticated),
      onLoginRequested: { user, password in
        if user == "user", password == "pass" {
          expectation.fulfill()
        }
      }
    )
    Just(LoginEvent.loginUsernameChanged("user"))
      .subscribe(loginBloc.subscriber)
    Just(LoginEvent.loginPasswordChanged("pass"))
      .subscribe(loginBloc.subscriber)
    Just(LoginEvent.tryLogin).subscribe(loginBloc.subscriber)
    wait(for: [expectation], timeout: 0.1)
  }
}
