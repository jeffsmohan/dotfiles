---
status: accepted
date: 2026-08-18
---

# Sign commits with SSH keys in the Secure Enclave

## Context and Problem Statement

For years, I've signed all my public commits and had Github's
[vigilant mode](https://docs.github.com/en/authentication/managing-commit-signature-verification/displaying-verification-statuses-for-all-of-your-commits)
on. I've historically used GPG to sign commits, but automating more of our setup via
`bootstrap.sh` makes GPG more difficult than necessary. It requires a secret key exported
from `~/.gnupg` and carried over by hand to a new device.

## Considered Options

- Keep GPG, carrying the secret key between machines
- SSH, per-machine key in the Secure Enclave (Secretive)
- SSH, per-machine key file in `~/.ssh`
- SSH, one key in 1Password
- SSH, one key on a FIDO2 token

## Decision

**SSH signatures, with a per-machine key generated in the Secure Enclave by
[Secretive](https://github.com/maxgoedjen/secretive), in the mode that does not prompt
while the Mac is unlocked.**

**Custody decides it.** GnuPG's model is one long-lived key you carry, and every way of
moving it ends with a secret in transit. GitHub accepts any number of registered SSH
signing keys, so "born on the machine, never leaves" becomes the natural shape.

**Prompt frequency is key.** We need to support AI agents creating commits in terminal,
where a prompt is a hang rather than a small friction. That rules out a FIDO2 token, which
needs a touch per signature, and 1Password, whose approval is scoped per session (and
requires paid subscription).

**Secretive needs less trust than a single-maintainer app suggests.** The key is generated
inside the Enclave, so the app cannot read it even if it wanted to — a hardware property
rather than a promise. Its bus factor of one is an availability risk, but migrating off is
pretty cheap.

**A passphrase-protected key file in `~/.ssh` is the near-miss and the fallback**, equally
per-machine and equally silent, losing only in that a file can be stolen once and used
forever.

## More Information

Nothing here configures local verification. SSH signatures carry no identity, so
`git log --show-signature` needs an allowed-signers file — untrackable in a public repo,
and stale as machines are added. GitHub never consults it, verifying server-side against
the registered keys, and the badge is the point. The GPG key stays registered so its
existing commits keep verifying.
