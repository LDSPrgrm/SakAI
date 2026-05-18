/// Feature gate for the OTP send/verify flow.
///
/// Set to `true` after `POST /auth/otp/send` and `POST /auth/otp/verify` ship
/// on the backend. While `false`, OTP screens render a "Coming soon" state
/// instead of attempting to call the (still-stubbed) repository.
const bool kOtpEnabled = false;
