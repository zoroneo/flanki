# Privacy Policy for Flanki

**Last Updated:** September 7, 2026

Flanki ("we", "our", or "the app") is an open-source, local-first spaced repetition flashcard application developed by ZoroNeo and contributors. We are committed to protecting your privacy. This Privacy Policy explains how information is handled when you use the Flanki application across Desktop (Windows, macOS, Linux) and Mobile (Android, iOS) platforms.

---

## 1. Summary (Core Principles)

- **Local-First:** All your decks, flashcards, study schedules, and review history are stored locally on your own device.
- **Zero Tracking:** We do not include third-party advertising SDKs, tracking frameworks, or behavioral analytics.
- **Zero Data Sale:** We do not collect, monetize, sell, or rent your personal data to data brokers or third parties.
- **Direct Sync Only:** If you choose to sync with AnkiWeb, your credentials and collection data are transmitted directly between your device and AnkiWeb servers over encrypted HTTPS.

---

## 2. Information We Collect and How It Is Handled

### A. Flashcard Data & Study Progress (Local Storage)
- **Data:** Cards, notes, decks, tags, review intervals, scheduling parameters (FSRS / SM-2), audio files, and images.
- **Storage Location:** Stored exclusively in a local SQLite database and local media directory on your device.
- **Access:** This data never leaves your device unless you explicitly initiate cloud synchronization.

### B. AnkiWeb Account & Synchronization (Optional)
- **Data:** Your AnkiWeb account email and password/session token.
- **Purpose:** To synchronize decks, cards, and media between your device and your personal AnkiWeb account.
- **Transmission:** All communication is made directly between the Flanki app on your device and `https://sync.ankiweb.net` via TLS/HTTPS encryption.
- **Credential Security:** Your authentication tokens are stored securely in your operating system's credential vault (`flutter_secure_storage`), utilizing Android Keystore, iOS Keychain, or Windows DPAPI. Flanki maintainers never receive, log, or have access to your credentials.

### C. App Updates (GitHub Releases)
- **Data:** Non-identifying HTTP request headers.
- **Purpose:** To notify you when a newer version of Flanki is released.
- **Transmission:** Queries the public GitHub Releases API (`https://api.github.com/repos/zoroneo/flanki/releases/latest`). No personal data or device identifiers are transmitted.

### D. System Notifications (Local Only)
- **Data:** Review reminders and streak alerts.
- **Mechanism:** Handled entirely by your device's local notification daemon (`flutter_local_notifications`). No external push notification servers (such as Firebase Cloud Messaging or APNs) are used.

---

## 3. Third-Party Services

When using Flanki, the following third-party services may be contacted based on your actions:

| Service | Purpose | Privacy Policy |
| :--- | :--- | :--- |
| **AnkiWeb** (Ankitects Pty Ltd) | Optional flashcard synchronization | [AnkiWeb Privacy Policy](https://ankiweb.net/account/terms) |
| **GitHub** (Microsoft Corporation) | Checking for application updates & releases | [GitHub Privacy Statement](https://docs.github.com/en/site-policy/privacy-policies/github-privacy-statement) |

---

## 4. Data Retention and Deletion

- **Local Data:** You have full control over your data. You can delete individual decks, clear the application cache, or completely uninstall the app to immediately delete all local data.
- **AnkiWeb Data:** If you use AnkiWeb synchronization, you can manage or delete your stored collection by logging into your account at [AnkiWeb.net](https://ankiweb.net).

---

## 5. Children's Privacy

Flanki does not knowingly collect or solicit personal information from children under the age of 13 (or under 16 in the European Union). The app can be used completely offline without providing any personal identifying information.

---

## 6. Security

We take data security seriously:
- Network traffic for sync and updates is strictly encrypted using industry-standard HTTPS / TLS.
- Authentication tokens are safeguarded using platform-native hardware-backed secure storage.
- The complete source code of Flanki is open and verifiable at [https://github.com/zoroneo/flanki](https://github.com/zoroneo/flanki).

---

## 7. Changes to This Privacy Policy

We may update this Privacy Policy periodically to reflect new features or regulatory requirements. Any changes will be posted in this repository with an updated "Last Updated" date.

---

## 8. Contact Us

If you have any questions or concerns regarding this Privacy Policy, please reach out by opening an issue on our GitHub repository:

- **GitHub Issues:** [https://github.com/zoroneo/flanki/issues](https://github.com/zoroneo/flanki/issues)
- **Project Repository:** [https://github.com/zoroneo/flanki](https://github.com/zoroneo/flanki)
