# Maintenance fork

This fork is maintained by Besideyou. The upstream project is
https://github.com/berkaycatak/adaptive_platform_ui and its MIT license and
copyright notices remain unchanged.

## Branch and dependency policy

- `main` preserves upstream history. Product fixes live on `besideyou/1.0.1`,
  based on upstream `v1.0.1` (`11fc9e5228f7af1c454009d92b2459c6ae4cd563`).
- Consumers pin a full Git commit SHA, not a moving branch or a local path.
- Keep portable fixes and regression tests in focused commits. Application
  branding, business rules and private integration evidence do not belong here.
- Before updating upstream, review changes and rerun affected tests and native
  checks. Remove local patches once equivalent fixes are available upstream.
- No pub.dev release or upstream pull request is implied by maintaining this
  fork. Contributions can be proposed separately once verified.

## Local patches

### iOS alert lifecycle

A Flutter dialog route could complete after an external pop while its native
UIAlertController remained visible. The patch dismisses the owned native alert
when its Flutter view is disposed, avoids retaining the platform view through
its channel handler, and guards actions against disabled, repeated or late
callbacks that might otherwise pop an underlying route.

`test/ios26_alert_dialog_lifecycle_test.dart` covers the shared action gate on
the Cupertino fallback. It does not simulate UIKit. Native external dismissal,
normal action callbacks and reopening require an iOS runtime check.

Validation on 2026-09-21: the three focused widget tests and targeted Dart
analysis pass. Xcode 26.6 compiled the patch for an iPhone 17 / iOS 26.5
simulator. An isolated host confirmed that external route dismissal removes
the native alert and dimming overlay, and that reopening and confirming returns
normally. This does not establish real-device or release-build coverage.
