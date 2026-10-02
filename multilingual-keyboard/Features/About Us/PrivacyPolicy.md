# Privacy Policy for Nepal Lipi Keyboard (Newa Keyboard)

**Effective Date:** October 2026  
**Developer:** Callijatra Team & Contributors  
**App Name:** Nepal Lipi Keyboard (multilingual-keyboard / nepa-key)

---

## 1. Our Privacy Philosophy: Privacy by Architecture
At Callijatra, we believe privacy is a fundamental human right. Nepal Lipi Keyboard was created to revitalize, preserve, and facilitate the typing of Nepal Lipi (Newa) and Devanagari scripts on iOS. 

We engineered Nepal Lipi Keyboard with a **zero-data-collection architecture**. We do not collect, monitor, store, sell, or transmit any data you type, any personal identifiers, or any information about your device. Everything you type remains solely and exclusively on your device.

---

## 2. Keystroke Privacy & Text Input (Zero Logging)
- **No Keystroke Logging:** The keyboard does not log, record, or track your keystrokes.
- **No Text Harvesting:** We never read, collect, copy, or transmit words, sentences, messages, emails, notes, passwords, usernames, phone numbers, or credit card information typed via the keyboard.
- **Direct System Passing:** When you tap a key or a transliterated character is generated, it is passed directly to the iOS `textDocumentProxy` of the active application. No intermediate copy is retained or sent anywhere.

---

## 3. 100% Offline & On-Device Processing
- **No Network Requests:** The keyboard extension (`nepa-key`) has **zero network communication capabilities**. It does not connect to external servers, APIs, or cloud backends.
- **Local Transliteration:** All transliteration algorithms (Roman to Devanagari and Roman to Nepal Lipi), character mappings, ligatures, and autocorrect rules (such as Ya + Virama ZWNJ formatting) execute locally on your device's processor in real-time.
- **Local Dictionaries:** All word lists and suggestion dictionaries reside locally inside the app bundle. They are queried entirely on-device without any internet dependency.
- **Air-Gapped Operation:** The keyboard operates fully and flawlessly in Airplane Mode without an internet connection.

---

## 4. Understanding iOS "Allow Full Access" Permission
When you enable Nepal Lipi Keyboard in **Settings → Keyboards**, iOS may present a standard system dialog asking whether to "Allow Full Access". 

### Why iOS Shows This Warning:
Apple displays a universal warning for all third-party keyboards stating:
> *"Full Access allows the developer of this keyboard to transmit anything you type..."*

### Our Guarantee:
Even if you enable "Allow Full Access", Nepal Lipi Keyboard **does NOT transmit anything you type**. 

On iOS, Full Access is requested exclusively for device-hardware capabilities:
1. **Haptic Feedback:** To trigger subtle vibrations using Apple's Taptic Engine (`UIImpactFeedbackGenerator`) when keys are pressed.
2. **Key Click Audio:** To play system key click sounds via `AudioServicesPlaySystemSound`.
3. **Shared Preferences:** To share your local settings (e.g. your chosen keyboard theme, selected language, and haptic preferences) between the main application and the keyboard extension via a local sandboxed App Group (`UserDefaults`).

**We never use Full Access to connect to the internet, track your typing, or access external data.**

---

## 5. No Third-Party Tracking or Advertising
- **No Analytics SDKs:** We do not integrate Google Firebase Analytics, Mixpanel, AppsFlyer, or any user telemetry SDKs in the keyboard extension.
- **No Advertising Frameworks:** We do not include any ad networks, trackers, or data brokers.
- **No IDFA Collection:** We do not read or access your Identifier for Advertisers (IDFA) or Identifier for Vendors (IDFV).

---

## 6. Local Storage & App Group Sandbox
- Any preferences you customize in the **Settings** tab (such as dark/light keyboard theme, sound effects toggle, or vibration toggle) are stored strictly on your local device within the private App Group sandbox (`group.com.callijatra.multilingual-keyboard`).
- These settings never leave your device and are never backed up to remote proprietary servers.

---

## 7. Sensitive Information & Secure Text Entry
- **Passwords:** iOS automatically switches back to the system keyboard for secure password fields. Nepal Lipi Keyboard never processes or accesses password inputs.
- **Financial Details:** Credit card numbers and authentication fields are handled directly by iOS; Nepal Lipi Keyboard does not capture or store payment details.

---

## 8. Compliance with Apple App Store Guidelines
Nepal Lipi Keyboard strictly adheres to:
- **Apple App Store Review Guideline 5.1.1 (Data Collection and Storage):** Only data essential for app functionality is handled, with transparent user consent.
- **Apple App Store Review Guideline 5.1.2 (Data Use and Sharing):** Keyboard extensions must not transmit keystrokes or user data.

---

## 9. Contact Us
If you have any questions, concerns, or requests regarding this Privacy Policy or the security of Nepal Lipi Keyboard, please contact us:
- **Organization:** Callijatra
- **Website:** [callijatra.com](https://callijatra.com)
- **Instagram:** [@callijatra](https://instagram.com/callijatra)
- **Facebook:** [/callijatra](https://facebook.com/callijatra)
- **Email:** contact@callijatra.com
