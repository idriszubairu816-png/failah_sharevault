# FAILAH ShareVault

Offline-first private file sharing, storage, and media playback for Android, with an
optional 1TB cloud tier. This repo is a **real, compiling-shaped Android Studio project
scaffold** — not a mockup — built around the architecture and constraints in the spec.

## What's fully implemented in this scaffold

- **Project structure & build config** — Gradle (Kotlin DSL), module layering (`ui` /
  `domain` / `data`), all real dependencies (no placeholders) for Compose, Room, Hilt,
  Nearby Connections, WorkManager, Media3, Retrofit.
- **Local peer-to-peer transfer** — `NearbyTransferManager` wraps Google Play services'
  **Nearby Connections API** (the current, non-deprecated way to do Xender-style discovery
  and transfer on Android — uses Bluetooth/BLE/Wi-Fi directly, zero internet required).
  Discovery, advertising, connection accept/reject, and payload streaming are wired for real.
- **Transfer engine** — `TransferEngine` consumes those P2P events, streams received files
  into private storage in 64KB chunks (never loads a whole file into RAM), computes a
  SHA-256 checksum, tracks live speed/ETA, and cleans up partial files on failure without
  ever touching the sender's original.
- **Private vault enforcement** — `VaultPaths` is the single place that resolves storage
  locations, and every one of them lives under `context.filesDir` (app-private). The only
  code path allowed to write to public/MediaStore storage is `ExportFileUseCase`, triggered
  solely by an explicit "Export to Device" tap.
- **Local database** — Room, encrypted at rest via SQLCipher with a passphrase derived from
  an Android Keystore-backed key (`FailahDatabase`, `KeystoreManager`). Schema covers file
  metadata, transfer history, and known/trusted devices per the spec.
- **Security** — PIN storage as a salted HMAC (never the raw PIN), per-file `EncryptedFile`
  wrapping, cleartext HTTP disabled app-wide, backup/device-transfer excluded for the vault.
- **Cloud client contract** — `CloudApi.kt` defines the real REST contract (auth, presigned
  upload/download, quota, file listing/delete/restore) and `CloudUploadWorker` does chunked,
  resumable uploads via WorkManager so they survive app kill and retry with backoff.
- **UI shell** — Compose navigation across all six required tabs (Home, Files, Send, Receive,
  Cloud, Settings), each backed by a real Hilt ViewModel wired to the DAOs/managers above.

## What's intentionally stubbed, and why

- **The cloud backend server itself** (auth service, quota enforcement, Postgres, presigned
  URL issuance). This is a separate service, not something that lives inside an Android
  project — see `docs/CLOUD_ARCHITECTURE.md` for exactly what it needs to be and why it
  can't be faked client-side.
- **Gallery/video/music player screens and the document viewer** — the data layer, private
  storage, and navigation entry points for these are in place; the Media3-based player UI
  and gallery grid are the next logical slice of work.
- A few small helpers (`EncryptedPrefsRaw`, `ImportFileUseCase` body) are marked with
  `// TODO` / comments pointing at the pattern to follow, to avoid duplicating the streaming
  copy + encryption logic that's already written elsewhere in full.

Nothing here fakes progress, fakes storage capacity, or claims a capability the code doesn't
back up — per the spec's explicit instruction not to fake transfer progress or cloud storage.

## Build instructions

1. Open the project root in Android Studio (Koala or newer).
2. Let Gradle sync — it will pull the dependencies listed in `app/build.gradle.kts`.
3. Run on a device or emulator with Google Play services (required for Nearby Connections).
   Two physical devices are needed to test real P2P transfer; emulators can't exercise
   Bluetooth/Wi-Fi Direct meaningfully.
4. Local features (vault, gallery/player scaffolding once built out, file manager) work with
   zero network connectivity, matching the offline-first requirement.

## Testing strategy

- **Unit tests** (`testImplementation` deps already added: JUnit, coroutines-test, Turbine):
  target `TransferEngine`'s speed/ETA math, `VaultPaths.uniqueTarget` de-duplication, and
  DAO query logic against an in-memory Room database.
- **Instrumented tests** (Espresso + Compose UI test deps included): navigation between the
  six tabs, PIN entry gate, and the accept/reject dialog flow.
- **Manual two-device testing** is required for the P2P transfer path itself — no emulator
  substitute exists for real Nearby Connections behavior.
- **Edge-case checklist** to script as tests once the transfer/cloud code is filled in:
  app killed mid-transfer, Wi-Fi toggled mid-transfer, receiver rejects, duplicate filename,
  insufficient storage, corrupted checksum, interrupted upload/download, network timeout —
  all called out explicitly in the spec's edge-case section.

## Deployment instructions

1. Generate a release signing key (`keytool -genkey -v -keystore failah-release.jks ...`)
   and wire it into `app/build.gradle.kts`'s `signingConfigs` (omitted here — don't commit
   the keystore or its password to source control).
2. Stand up the backend described in `docs/CLOUD_ARCHITECTURE.md` and point `CloudApi`'s
   Retrofit base URL at it via build-config fields (debug vs. release endpoints).
3. Build the release bundle: `./gradlew bundleRelease`, then upload the `.aab` to Play
   Console. Nearby Connections and biometrics both work fine under standard Play distribution
   — no special entitlements needed.
4. Before the cloud tier goes live, load-test the presigned-URL issuance path and confirm
   server-side quota enforcement actually rejects uploads past 1TB — don't rely on the
   client's own quota display as the enforcement mechanism.

## Branding

App name shown on launcher/splash/main UI: **FAILAH**. Full product name: **FAILAH
ShareVault**. Colors/logo in `ui/theme/Theme.kt` are placeholders — swap in real brand
assets (`res/mipmap-anydpi-v26/ic_launcher.xml`, `res/values/themes.xml` colors) whenever
they're ready; nothing else in the codebase depends on the specific placeholder values.
