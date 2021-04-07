//
//  AuthenticationBloc.swift
//  Login
//
//  Created by Wellington Soares on 26/03/21.
//

import Combine
import CombineBloc
import Foundation

enum AuthenticationEvent: Equatable {
    case AuthenticatedUserChanged(Result<User, AuthenticationRepositoryError>)
    case AuthenticationLogoutRequested
    case AuthenticationLoginRequested(username: String, password: String)
}

enum AuthenticationState: Equatable {
    case authenticated(User)
    case unknown
    case unauthenticated(AuthenticationRepositoryError)
    case authenticating(_ username: String, _ password: String)
}

final class AuthenticationBloc: Bloc<AuthenticationEvent, AuthenticationState> {
    private var cancellable: AnyCancellable?
    private let repository: AuthenticationRepository

    init(repository: AuthenticationRepository) {
        self.repository = repository

        super.init(initialValue: AuthenticationState.unknown) { event, _, emit in
            switch event {
            case let .AuthenticatedUserChanged(userResult):
                switch userResult {
                case let .success(user):
                    emit(AuthenticationState.authenticated(user))
                case let .failure(error):
                    emit(AuthenticationState.unauthenticated(error))
                }
            case .AuthenticationLogoutRequested:
                repository.logOut()

            case let .AuthenticationLoginRequested(username, password):
                emit(AuthenticationState.authenticating(username, password))
                repository.logIn(username: username, password: password)
            }
        }
        cancellable = repository.user.sink { userResult in
            Just(.AuthenticatedUserChanged(userResult)).subscribe(self.subscriber)
        }
    }

    override func cancel() {
        cancellable?.cancel()
        super.cancel()
    }
}
