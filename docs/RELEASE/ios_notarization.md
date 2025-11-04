# iOS/macOS Notarization (Overview)

- Ensure Developer ID certificates installed
- Codesign app bundle
- Notarize: `xcrun notarytool submit <.zip/.pkg> --keychain-profile <profile> --wait`
- Staple: `xcrun stapler staple <app>`

See Apple docs for full steps.
