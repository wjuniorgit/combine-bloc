//
//  PasswordField.swift
//  Login
//
//  Created by Wellington Soares on 01/05/21.
//

import SwiftUI

struct PasswordField: View {
  let loginFormState: LoginFormState
  let text: String
  let set: (String) -> ()

  var body: some View {
    LoginInputField(label: "Password", loginFormState: loginFormState, isPassword: true, icon: Image(systemName: "lock"), text: text, set: set)
  }
}

