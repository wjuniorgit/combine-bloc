//
//  LoginView.swift
//  mock
//
//  Created by Wellington Soares on 05/03/21.
//

import Combine
import CombineBloc
import SwiftUI

struct LoginView: View {
  var loginBloc: Bloc<LoginEvent, LoginState>

  var body: some View {
    StateViewBuilder(bloc: loginBloc) {
      state in
      VStack {
        Text("Welcome!")
          .font(.largeTitle)
          .fontWeight(.semibold)
          .padding()

        UsernameField(loginFormState: state.loginFormState, text: state.userName) {
          Just(.loginUsernameChanged($0)).subscribe(loginBloc.subscriber)
        }
        PasswordField(loginFormState: state.loginFormState, text: state.password) {
          Just(.loginPasswordChanged($0)).subscribe(loginBloc.subscriber)
        }

        LoginButton(loginFormState: state.loginFormState){
          Just(.tryLogin).subscribe(loginBloc.subscriber)
        }

        Text("Incorrect credentials").opacity(state.loginFormState == .retry ? 1.0 : 0.0)

      }
    }
  }
}
