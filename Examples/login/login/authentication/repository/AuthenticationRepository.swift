//
//  AuthenticationRepository.swift
//  Login
//
//  Created by Wellington Soares on 26/03/21.
//

import Combine
import Foundation

struct User: Equatable {
  let id: String
  let name: String

  init(id: String, name: String) {
    self.id = id
    self.name = name
  }
}

enum AuthenticationRepositoryError: Error, Equatable {
  case incorrectCredentials(_ username: String, _ password: String)
  case unauthenticated
}

protocol AuthenticationRepository {
  func logIn(username: String, password: String)
  func logOut()
  var user: AnyPublisher<Result<User, AuthenticationRepositoryError>, Never> {
    get
  }
}

final class MockAuthRepository: AuthenticationRepository {
  var user: AnyPublisher<Result<User, AuthenticationRepositoryError>, Never> {
    subject.eraseToAnyPublisher()
  }

  func logOut() {
    cancellable = Just(
      Result
        .failure(AuthenticationRepositoryError.unauthenticated)
    ).assign(
      to: \.subject.value,
      on: self
    )
  }

  func logIn(username: String, password: String) {
    if username == "user", password == "pass" {
      cancellable = Just(Result.success(User(id: "123", name: username)))
        .delay(for: 2, scheduler: RunLoop.main)
        .assign(to: \.subject.value, on: self)
    } else {
      cancellable = Just(
        Result
          .failure(
            AuthenticationRepositoryError
              .incorrectCredentials(username, password)
          )
      )
      .delay(for: 2, scheduler: RunLoop.main)
      .assign(to: \.subject.value, on: self)
    }
  }

  private var subject = CurrentValueSubject<
    Result<User, AuthenticationRepositoryError>,
    Never
  >(Result.failure(AuthenticationRepositoryError.unauthenticated))
  private var cancellable: AnyCancellable?
}
