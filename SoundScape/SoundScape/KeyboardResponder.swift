//
//  KeyboardResponder.swift
//  SoundScape
//
//  Created by 오도영 on 2/14/25.
//

import Foundation
import SwiftUI
import Combine

class KeyboardResponder: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0

    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .sink { [weak self] notification in
                guard let self = self else { return }
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    DispatchQueue.main.async {
                        self.keyboardHeight = notification.name == UIResponder.keyboardWillHideNotification ? 0 : keyboardFrame.height
                    }
                }
            }
    }
}
