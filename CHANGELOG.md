# Changelog

All notable changes to BLU Classic will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.2] - 2025-01-21

### Fixed
- Updated .pkgmeta file for proper BLU_Classic packaging
- Fixed BigWigs packager configuration to package as BLU_Classic
- Corrected manual-changelog path to use CHANGELOG.md

## [1.0.1] - 2025-01-21

### Fixed
- Removed incorrect BLU (non-Classic) TOC files from repository
- Cleaned up repository to only contain BLU_Classic TOC files

### Changed
- Repository now properly contains only BLU_Classic addon files

## [1.0.0] - 2025-01-21

### Added
- Initial release of BLU Classic
- Universal support for ALL World of Warcraft versions
- Dedicated TOC files for each WoW version:
  - `BLU_Classic.toc` - Default/Retail/The War Within (Interface: 110105)
  - `BLU_Classic_Vanilla.toc` - Classic Era/Vanilla/Hardcore/SoD (Interface: 11507)
  - `BLU_Classic_BCC.toc` - Burning Crusade Classic (Interface: 20504)
  - `BLU_Classic_Wrath.toc` - Wrath of the Lich King Classic (Interface: 30403)
  - `BLU_Classic_Cata.toc` - Cataclysm Classic (Interface: 40402)
  - `BLU_Classic_Mists.toc` - Mists of Pandaria Classic (Interface: 50500)
  - `BLU_Classic_Classic.toc` - Generic Classic version support
- RGX Mods branding and community integration
- Over 50 game sounds to choose from
- Individual volume controls for each sound type
- Slash commands: `/blu`, `/blu help`, `/blu debug`, `/blu welcome`

---

## Version Guidelines

- **Major version (X.0.0)**: Breaking changes or major feature additions
- **Minor version (0.X.0)**: New features, non-breaking changes
- **Patch version (0.0.X)**: Bug fixes, minor improvements

## Links

- [GitHub Repository](https://github.com/donniedice/BLU_Classic)
- [Issue Tracker](https://github.com/donniedice/BLU_Classic/issues)
- [Discord Community](https://discord.gg/N7kdKAHVVF)

[Unreleased]: https://github.com/donniedice/BLU_Classic/compare/v1.0.2...HEAD
[1.0.2]: https://github.com/donniedice/BLU_Classic/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/donniedice/BLU_Classic/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/donniedice/BLU_Classic/releases/tag/v1.0.0