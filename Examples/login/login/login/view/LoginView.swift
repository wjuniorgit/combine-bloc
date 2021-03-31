//
//  LoginView.swift
//  mock
//
//  Created by Wellington Soares on 05/03/21.
//

import SwiftUI
import Combine
import CombineBloc

struct LoginView: View {
    var loginBloc: Bloc<LoginEvent, LoginState>

    var body: some View {

            BlocViewBuilder(bloc: loginBloc) {
                state in
                VStack {
                    Text("Welcome!")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding()
                    HStack {
                        Image(systemName: "person")
                        TextField("Username", text: Binding(get: { state.userName }, set: {
                            Just(.loginUsernameChanged($0)).subscribe(loginBloc.subscriber)
                        })
                        ).autocapitalization(.none).disabled(state.loginFormState == .submitting ? true : false)


                    } .padding()
                        .border(state.loginFormState == .retry ? Color.pink : Color.blue, width: 2)
                        .background(Color(white: 0.9))
                        .cornerRadius(5.0)
                        .padding()


                    HStack {
                        Image(systemName: "lock")
                        SecureField("Password", text: Binding(get: { state.password }, set: {
                            Just(.loginPasswordChanged($0)).subscribe(loginBloc.subscriber)
                        })).autocapitalization(.none).disabled(state.loginFormState == .submitting ? true : false)
                    }
                        .padding()
                        .border(state.loginFormState == .retry ? Color.pink : Color.blue, width: 2)
                        .background(Color(white: 0.9))
                        .cornerRadius(5.0)
                        .padding()
                        .disabled(state.loginFormState == .submitting ? true : false)
                    Button(action: {
                        Just(.tryLogin).subscribe(loginBloc.subscriber)
                    }) {
                        HStack {
                            if(state.loginFormState == .submitting) {
                                ProgressView()
                            }
                            Text("LOGIN")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 220, height: 60)
                                .background(Color.green)
                                .cornerRadius(5.0)
                                .padding()
                        }
                    }.disabled(state.loginFormState == .submitting ? true : false)

                    if(state.loginFormState == .retry) {
                        Text("Try again")
                    }
                }
            }


    }
}
