//
//  AuthView.swift
//  mock-bloc
//
//  Created by Wellington Soares on 08/03/21.
//

import Combine
import CombineBloc
import SwiftUI

struct AuthenticationView: View {
  var authenticationBloc: Bloc<AuthenticationEvent, AuthenticationState>

  init(authenticationBloc: Bloc<AuthenticationEvent, AuthenticationState>) {
    self.authenticationBloc = authenticationBloc
  }

  func createLoginView(_ authenticationBloc: Bloc<
    AuthenticationEvent,
    AuthenticationState
  >) -> LoginView {
    LoginView(loginBloc: LoginBloc(
      authenticationState: authenticationBloc.value,
      onLoginRequested: { username, password in
        Just(.AuthenticationLoginRequested(
          username: username,
          password: password
        )).subscribe(authenticationBloc.subscriber)
      }
    ))
  }

  var body: some View {
    VStack {
      StateViewBuilder(bloc: authenticationBloc) {
        state in
        switch state {
        case .unknown:
          ProgressView()
        case .unauthenticated:
          createLoginView(authenticationBloc)
        case .authenticating:
          createLoginView(authenticationBloc)
        case let .authenticated(user):
          HomeView(user: user, authenticationBloc: authenticationBloc)
        }
      }
    }
  }
}
