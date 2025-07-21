# Changelog

All notable changes to BLU Classic will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2024-01-20

### Added
- Initial release of BLU Classic
- Forked from BLU v5.2.4 to support ALL World of Warcraft versions
- Support for ALL WoW versions with dedicated TOC files:
  - `BLU_Classic.toc` - Default/Retail/The War Within (Interface: 110105)
  - `BLU_Classic_Vanilla.toc` - Classic Era/Vanilla/Hardcore/SoD (Interface: 11507)
  - `BLU_Classic_BCC.toc` - Burning Crusade Classic (Interface: 20504)
  - `BLU_Classic_Wrath.toc` - Wrath of the Lich King Classic (Interface: 30403)
  - `BLU_Classic_Cata.toc` - Cataclysm Classic (Interface: 40402)
  - `BLU_Classic_Mists.toc` - Mists of Pandaria Classic (Interface: 50500)
  - `BLU_Classic_Classic.toc` - Generic Classic version support
- RGX Mods branding and community integration
- Professional README with Discord community links
- GitHub Actions workflow for automated releases
- Over 50 game sounds to choose from
- Individual volume controls for each sound type
- Slash commands: `/blu`, `/blu help`, `/blu debug`, `/blu welcome`

### Changed
- Renamed addon from "BLU" to "BLU Classic" (supports ALL versions)
- Updated version numbering to start fresh at v1.0.0
- Created TOC files for every WoW version
- Enhanced documentation with RGX Mods branding
- Updated author email to 60427166+donniedice@users.noreply.github.com
- Updated addon paths from BLU to BLU_Classic

### Removed
- Battle Pet level-up sounds (Retail only)
- Trading Post activity sounds (Retail only)
- Honor rank sounds (Retail only)
- Renown reputation sounds (Retail only)
- Delve Companion sounds (Retail only)

### Fixed
- Ensured all paths reference BLU_Classic instead of BLU
- Updated icon texture paths in TOC files

## Pre-Fork History

For changes prior to the Classic fork, please see the original [BLU changelog](https://github.com/donniedice/BLU/blob/main/docs/changelog.txt).

---

## Version Guidelines

- **Major version (X.0.0)**: Breaking changes or major feature additions
- **Minor version (0.X.0)**: New features, non-breaking changes
- **Patch version (0.0.X)**: Bug fixes, minor improvements

## Links

- [GitHub Repository](https://github.com/donniedice/BLU_Classic)
- [Issue Tracker](https://github.com/donniedice/BLU_Classic/issues)
- [Discord Community](https://discord.gg/N7kdKAHVVF)

[Unreleased]: https://github.com/donniedice/BLU_Classic/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/donniedice/BLU_Classic/releases/tag/v1.0.0