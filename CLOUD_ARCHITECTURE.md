# FAILAH Cloud: what "1TB per account" actually requires

An Android APK cannot create storage capacity. The 1000GB/account tier has to be real
object storage sitting behind a real backend that FAILAH's app talks to over the internet.
This doc is the explanation the spec asked for before any cloud backend gets implemented.

## Required components (none of these ship inside the app)

1. **Object storage** — where the bytes actually live. Options, roughly cheapest-to-most-managed:
   - **Backblaze B2** — cheapest at scale for this kind of workload (~$6/TB/month stored,
     free egress up to 3x storage via bandwidth alliance with some CDNs). S3-compatible API.
   - **Cloudflare R2** — no egress fees at all, S3-compatible, good if users download a lot.
   - **AWS S3** — most mature tooling/ecosystem, higher egress cost, easy multipart upload
     support for large-file resumability.
   - **Wasabi** — flat-rate, S3-compatible, no egress fees, simple pricing.
   All four speak the same S3 API dialect, so the backend can be written against that API
   and the provider can be swapped later without touching client code.

2. **A backend API server** (this is what `CloudApi.kt` in the app targets) — handles:
   - Account registration/login, issuing short-lived access tokens + refresh tokens
   - Per-user quota enforcement (1TB) — checked server-side on every upload-init call,
     never trusted from the client
   - Issuing presigned upload/download URLs so large files go directly between the phone
     and object storage, not through the API server's own bandwidth
   - File metadata (name, folder, size, checksum) in a real database (Postgres is the
     standard choice) separate from the object storage itself
   - Multipart/resumable upload coordination (tracking which parts of a large file have
     landed, for the "resume interrupted uploads" requirement)

3. **Auth** — either roll a standard email/password + JWT flow, or use a managed identity
   provider (AWS Cognito, Auth0, Firebase Auth) to avoid maintaining password storage/reset
   flows yourselves.

## Why not just point the app at S3 directly with an embedded key?

Because any credential embedded in an APK can be extracted, and a client-only design has no
way to enforce the "1TB and no more" limit — a user could just keep uploading past it, and
you'd have no ability to bill or throttle anything. The API-server-in-the-middle pattern
(app → your API → presigned URL → object storage) is the standard architecture used by every
consumer cloud storage product for exactly this reason.

## Cost shape (rough, for planning only — get current pricing before committing)

- Storage cost scales roughly linearly with (number of paying users) × (average GB actually
  used, which is usually well under the 1TB ceiling most users never fill).
- Egress (download) cost matters more than storage cost for an app people actively use —
  this is the strongest argument for R2 or a B2+CDN combination over raw S3 if usage is
  download-heavy.
- Compute cost for the API server itself is small relative to storage/egress at any
  meaningful scale — a couple of small server instances behind a load balancer, or a
  serverless API (Lambda/Cloud Run), is plenty to start.

## What's in this scaffold vs. what a backend team still needs to build

**In this scaffold:** the client-side contract (`CloudApi.kt`), a resumable chunked upload
worker (`CloudUploadWorker.kt`) built on WorkManager so it survives process death and retries
with backoff, and the clear LOCAL vs. CLOUD separation in the UI/data model.

**Not in this scaffold, because it's a separate service, not an Android app concern:** the
actual backend server (auth, quota enforcement, presigned URL issuance, Postgres schema,
billing if this becomes a paid tier). That's a normal backend project — happy to help design
or build it as a follow-up, in whatever stack you want (Node/Express, Go, Django, etc.).
