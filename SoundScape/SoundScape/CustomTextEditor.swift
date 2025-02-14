//
//  CustomTextEditor.swift
//  SoundScape
//
//  Created by 오도영 on 2/14/25.
//

import Foundation
import SwiftUI

/// ✅ 키보드에 "완료" 버튼 추가한 커스텀 TextEditor
struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.isScrollEnabled = true
        textView.backgroundColor = UIColor.white
        textView.layer.cornerRadius = 12
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.borderWidth = 1
        textView.delegate = context.coordinator

        // ✅ 키보드에 "완료" 버튼 추가
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let closeButton = UIBarButtonItem(title: "완료", style: .done, target: textView, action: #selector(textView.resignFirstResponder))
        toolbar.items = [closeButton]
        textView.inputAccessoryView = toolbar

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEditor

        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}
