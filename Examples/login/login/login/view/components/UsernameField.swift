//
//  UsernameField.swift
//  Login
//
//  Created by Wellington Soares on 01/05/21.
//

import SwiftUI

struct UsernameField: View {
  let loginFormState: LoginFormState
  let text: String
  let set: (String) -> Void

  var body: some View {
    LoginInputField(
      label: "Username",
      loginFormState: loginFormState,
      text: text,
      set: set
    )
  }
}
