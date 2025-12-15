import SwiftUI
import UIKit

struct KeyboardDismissalModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(KeyboardDismissalTapInterceptor())
            .onSubmit {
                dismissKeyboard()
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        dismissKeyboard()
                    }
                }
            }
            .onDisappear {
                dismissKeyboard()
            }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

extension View {
    func keyboardDismissal() -> some View {
        modifier(KeyboardDismissalModifier())
    }
}
