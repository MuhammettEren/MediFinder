import SwiftUI

/// Reusable error state view with retry action.
struct ErrorStateView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(Color.actionRed)

            Text(message)
                .font(.bodyXLarge(.semibold))
                .foregroundStyle(Color.labelPrimary)
                .multilineTextAlignment(.center)

            MainReusableButton(title: "Tekrar dene", style: .custom(bg: .actionBlue, fg: .labelWhite), width: 180) {
                retryAction()
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity)
    }
}
