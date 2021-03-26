//
//  HomeView.swift
//  Login
//
//  Created by Wellington Soares on 26/03/21.
//

import SwiftUI
import Combine
import CombineBloc

struct HomeView: View {
    let user: User
    let authenticationBloc: Bloc<AuthenticationEvent, AuthenticationState>

    var body: some View {

        VStack {
            Text("Welcome \(user.name)! ")
            Button(action: {
                Just(.AuthenticationLogoutRequested).subscribe(authenticationBloc)
            }) {
                Text("LOGOUT")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.green)
                    .cornerRadius(5.0)
                    .padding()
            }
        }
    }
}
