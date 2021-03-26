//
//  authBloc.swift
//  mock
//
//  Created by Wellington Soares on 05/03/21.
//

import Foundation
import Combine
import CombineBloc


enum LoginEvent: Equatable {
    case loginUsernameChanged(String)
    case loginPasswordChanged(String)
    case tryLogin
}

enum LoginFormState {
    case clean
    case retry
    case submitting
}

struct LoginState: Equatable {
    let userName: String
    let password: String
    let loginFormState: LoginFormState
}

extension LoginState {
    init() {
        self.init(userName: "", password: "", loginFormState: LoginFormState.clean)
    }
    func copyWith(userName: String? = nil, password: String? = nil, loginFormState: LoginFormState? = nil) -> LoginState {
        let userName = userName ?? self.userName
        let password = password ?? self.password
        let loginFormState = loginFormState ?? self.loginFormState
        return LoginState(userName: userName, password: password, loginFormState: loginFormState)
    }
}


final class LoginBloc: Bloc<LoginEvent, LoginState> {

    init(authenticationState: AuthenticationState, onLoginRequested:@escaping (_ username:String,_ password:String)->()
    ) {

        func loginStateFromAuthenticationState (_ authenticationState:AuthenticationState) -> LoginState{
            switch authenticationState {
            case .authenticated(_):
                return LoginState()
            case .authenticating(let username, let password):
                return LoginState(userName: username, password: password, loginFormState: LoginFormState.submitting)
            case .unauthenticated(let error):
            switch error {
            case .incorrectCredentials(let username, let password):
                return LoginState(userName: username, password: password, loginFormState: LoginFormState.retry)
            case.unauthenticated:
                return LoginState()
            }
            case.unknown:
                return LoginState()
            }
        }

        let initialLoginState = loginStateFromAuthenticationState(authenticationState)

        super.init(initialValue: initialLoginState)
        { event, state, emit in
            switch event {
            case .loginUsernameChanged(let userName):
                emit(state.copyWith(userName: userName))
            case .loginPasswordChanged(let password):
                emit(state.copyWith(password: password))
            case .tryLogin:
                onLoginRequested(state.userName,state.password)
            }
        }

    }
}
