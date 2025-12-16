# Changelog

All notable changes to eMark will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Document upcoming features here

### Fixed
- Document bug fixes here

### Changed
- Document changes here

## [1.0.6] - 2025-01-XX

### Fixed

- macOS file selection issue where PDF files in Documents and other protected folders are now accessible
- JFileChooser now properly shows and allows selection of PDF files on macOS

### Changed

- Switched from native macOS FileDialog back to Java-based JFileChooser for consistent cross-platform behavior
- Unified file selection dialog across all platforms (Windows, Linux, macOS) using JFileChooser

## [1.0.5] - 2025-01-XX

### Fixed

- macOS native FileDialog PDF files appearing grayed out and unselectable
- Removed FilenameFilter interference with macOS file selection, now validates PDF extension after selection

### Changed

- Improved macOS file selection by using post-selection validation instead of filename filtering

## [1.0.4] - 2025-01-XX

### Added
- Native macOS file dialog for better file system access
- Full file system permissions for macOS (Documents, Downloads, Desktop, removable volumes, network shares)
- DMG detection warning when running app directly from disk image
- Enhanced installation instructions in DMG

### Fixed
- macOS file chooser not showing PDF files in protected folders
- macOS app not persisting after Security & Privacy approval
- PKCS11 file filter showing .dll instead of .dylib on macOS
- Case-sensitive macOS OS detection bug
- Leading space typo in PKCS11 library path
- GitHub Actions changelog generation skipping for releases after first

### Changed
- macOS uses native FileDialog instead of JFileChooser for better permissions
- Simplified macOS installer to single 4GB memory profile
- Added comprehensive macOS file access entitlements
- Improved DMG installation workflow and documentation

## [1.0.3] - 2025-01-XX

### Changed
- Updated version to 1.0.3

## [1.0.2] - 2025-01-XX

### Changed
- Updated version to 1.0.2

## [1.0.1] - 2025-01-XX

### Changed
- Updated version to 1.0.1

## [1.0.0] - 2025-01-XX

### Added
- Initial release of eMark
- PDF signing with Windows Certificate Store
- PDF signing with PKCS#11/HSM devices
- PDF signing with PFX files
- Cross-platform support (Windows, Linux, macOS)
- Bundled JRE installers for all platforms

[Unreleased]: https://github.com/testaxonatetech/emark/compare/v1.0.6...HEAD
[1.0.6]: https://github.com/testaxonatetech/emark/compare/v1.0.5...v1.0.6
[1.0.5]: https://github.com/testaxonatetech/emark/compare/v1.0.4...v1.0.5
[1.0.4]: https://github.com/testaxonatetech/emark/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/testaxonatetech/emark/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/testaxonatetech/emark/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/testaxonatetech/emark/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/testaxonatetech/emark/releases/tag/v1.0.0
