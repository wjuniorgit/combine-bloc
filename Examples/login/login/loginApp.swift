//
//  LoginApp.swift
//  Login
//
//  Created by Wellington Soares on 26/03/21.
//

import SwiftUI

@main
struct LoginApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

struct ContentView: View {
  var body: some View {
    AuthenticationView(
      authenticationBloc: AuthenticationBloc(repository: MockAuthRepository())
    )
  }
}
