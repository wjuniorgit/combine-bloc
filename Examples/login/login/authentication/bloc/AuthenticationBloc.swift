//
//  AuthenticationBloc.swift
//  Login
//
//  Created by Wellington Soares on 26/03/21.
//

import Foundation
import Combine
import CombineBloc


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

    init(repository: AuthenticationRepository = StandardAuthRepository()) {
        self.repository = repository

        super.init(initialValue: AuthenticationState.unknown)
        { event, _, emit in
            switch event {
            case .AuthenticatedUserChanged(let userResult):
                switch userResult {
                case .success(let user):
                    emit(AuthenticationState.authenticated(user))
                case .failure(let error):
                    emit(AuthenticationState.unauthenticated(error))
                }
            case .AuthenticationLogoutRequested:
                repository.logOut()

            case .AuthenticationLoginRequested(let username, let password):
                emit(AuthenticationState.authenticating(username, password))
                repository.logIn(username: username, password: password)
            }
        }
        self.cancellable = repository.user.sink { userResult in
            Just(.AuthenticatedUserChanged(userResult)).subscribe(self.subscriber)
        }

    }

    override func cancel() {
        cancellable?.cancel()
        super.cancel()
    }

}
