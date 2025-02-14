//
//  UiApplication.swift
//  SoundScape
//
//  Created by 오도영 on 2/14/25.
//

import Foundation
import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
