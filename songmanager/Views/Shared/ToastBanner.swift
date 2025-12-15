import SwiftUI

struct ToastBanner: View {
    let message: String
    var actionTitle: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 8)
            if let actionTitle, let onAction {
                Button(actionTitle, action: onAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(color: Color.black.opacity(0.15), radius: 10, y: 4)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 24)
    }
}
