# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Added

- Initial MongoDB replica-set and sharded-cluster module implementation.
- Managed IPv4 allowlists, database-scoped accounts, instance parameters, and SSL state.
- Restore-to-new-instance inputs for backup-set and point-in-time recovery.
- Independent `basic` and `complete` examples with English and Chinese documentation.
- Real-cloud validation report for Terraform 1.5.7 and Provider 0.0.71.

### Changed

- Serialize SSL enablement before account creation to avoid MongoDB running-action conflicts.
- Require `admin` as the account authentication database because Provider 0.0.71 cannot delete accounts in other authentication databases.
- Ignore write-only account passwords and unstable parameter read-back after creation.
- Remove continuously changing backup and recoverable-time outputs to keep second plans stable.
