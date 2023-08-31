import SwiftUI

struct MenuView: View {
  private let items: [MenuItem] = [
    .banner,
    .interstitial,
    .native,
    .rewarded,
    .rewardedInterstitial,
  ]

  @State private var isMenuItemDisabled = true
  @State private var isPrivacyOptionsButtonDisabled = true
  @State private var hasAppeared = false
  @State private var showPrivacyOptionsAlert = false
  @State private var formErrorDescription: String?
  private let formViewControllerRepresentable = FormViewControllerRepresentable()

  var formViewControllerRepresentableView: some View {
    formViewControllerRepresentable
      .frame(width: .zero, height: .zero)
  }

  var body: some View {
    NavigationView {
      List(items) { item in
        NavigationLink(destination: item.contentView) {
          Text(item.rawValue)
        }
        .disabled(isMenuItemDisabled)
      }
      .navigationTitle("Menu")
      .background(formViewControllerRepresentableView)
      .toolbar {
        Button("Privacy Settings") {
          GoogleMobileAdsConsentManager.shared.presentPrivacyOptionsForm(
            from: formViewControllerRepresentable.viewController
          ) { formError in
            guard let formError else { return }

            formErrorDescription = formError.localizedDescription
            showPrivacyOptionsAlert = true
          }
        }
        .disabled(isPrivacyOptionsButtonDisabled)
      }
      .alert(isPresented: $showPrivacyOptionsAlert) {
        Alert(
          title: Text(formErrorDescription ?? "Error"),
          message: Text("Please try again later."))
      }
    }
    .onAppear {
      guard !hasAppeared else { return }
      hasAppeared = true

      GoogleMobileAdsConsentManager.shared.gatherConsent(
        from: formViewControllerRepresentable.viewController
      ) { consentError in

        if let consentError {
          // Consent gathering failed.
          print("Error: \(consentError.localizedDescription)")
        }

        isMenuItemDisabled = !GoogleMobileAdsConsentManager.shared.canRequestAds
        isPrivacyOptionsButtonDisabled = !GoogleMobileAdsConsentManager.shared
          .isPrivacyOptionsRequired

        GoogleMobileAdsConsentManager.shared.startGoogleMobileAdsSDK()
      }

      // This sample attempts to load ads using consent obtained in the previous session.
      GoogleMobileAdsConsentManager.shared.startGoogleMobileAdsSDK()
    }
  }
}

// MARK: - Helper to present UMP consent form
private struct FormViewControllerRepresentable: UIViewControllerRepresentable {
  let viewController = UIViewController()

  func makeUIViewController(context: Context) -> some UIViewController {
    return viewController
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

struct MenuView_Previews: PreviewProvider {
  static var previews: some View {
    MenuView()
  }
}
