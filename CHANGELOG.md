## [2.0.3](https://github.com/armiiller/deferred_request/compare/v2.0.2...v2.0.3) (2026-07-14)


### Bug Fixes

* release process ([df06ba8](https://github.com/armiiller/deferred_request/commit/df06ba869176288b91b7a2ee8e21b41a6a0abd4f))
* remove deferred_request from Gemfile.lock CHECKSUMS to fix frozen mode CI failure ([8f16825](https://github.com/armiiller/deferred_request/commit/8f168250b72f920d623fbf7f62addf63e20b7d97))
* unfreeze bundler in release step so Gemfile.lock can be updated ([9466470](https://github.com/armiiller/deferred_request/commit/9466470a4c4d0b66f75d63317df3f50805a5c254))

# Changelog

## [2.0.2](https://github.com/armiiller/deferred_request/compare/v2.0.1...v2.0.2) (2026-06-30)


### Bug Fixes

* add missing checksum for deferred_request in Gemfile.lock ([30ee235](https://github.com/armiiller/deferred_request/commit/30ee2357adacfdc9cc90ad765ff28b4bad022b74))

## [2.0.1](https://github.com/armiiller/deferred_request/compare/v2.0.0...v2.0.1) (2026-06-30)


### Bug Fixes

* add missing checksum for deferred_request in Gemfile.lock ([0e85773](https://github.com/armiiller/deferred_request/commit/0e85773f3cfd541fa79118a2286dc20f1d39a86e))

## [2.0.0](https://github.com/armiiller/deferred_request/compare/v1.0.4...v2.0.0) (2026-06-30)


### ⚠ BREAKING CHANGES

* minimum supported Rails version is now 7.1 (previously >= 6.0.0). Apps on Rails 6.x or 7.0 must upgrade Rails before bumping this gem.

### Features

* require Rails 7.1+ and Ruby 3.4+, drop Appraisal-based multi-version testing ([0d5b5ad](https://github.com/armiiller/deferred_request/commit/0d5b5adf1f0b301693cb032312521e9cca0fbdf0))


### Bug Fixes

* include the actual body of the request not just parsed params ([47ab87e](https://github.com/armiiller/deferred_request/commit/47ab87ee9d79730f408754b8970499f23758d494))

## [1.0.4](https://github.com/armiiller/deferred_request/compare/v1.0.3...v1.0.4) (2022-08-02)


### Bug Fixes

* rubygems otp settings ([68df7a0](https://github.com/armiiller/deferred_request/commit/68df7a022a6093d53f23b02a456f9ec835179a58))

## [1.0.3](https://github.com/armiiller/deferred_request/compare/v1.0.2...v1.0.3) (2022-08-02)


### Bug Fixes

* use json columns for serialized attributes ([a532e1b](https://github.com/armiiller/deferred_request/commit/a532e1b34a13c14a3a7ec1f19ccfe7e7cc0c3af2))

### [1.0.2](https://github.com/armiiller/deferred_request/compare/v1.0.1...v1.0.2) (2022-02-22)


### Bug Fixes

* add convinience methods and better documentation ([40e01fd](https://github.com/armiiller/deferred_request/commit/40e01fdea0eb3151a9548ad45b2d68c9da1d96e7))

### [1.0.1](https://github.com/armiiller/deferred_request/compare/v1.0.0...v1.0.1) (2022-02-07)


### Bug Fixes

* Adding Tests ([#2](https://github.com/armiiller/deferred_request/issues/2)) ([3fd620b](https://github.com/armiiller/deferred_request/commit/3fd620b3729828e9ba9ccef371057a58ccfaa674))

## 1.0.0 (2022-02-06)


### Features

* stable 0.1.0 ([4226e04](https://github.com/armiiller/deferred_request/commit/4226e04552a0fb05c04f404230fcd65b50233fa1))


### Bug Fixes

* branchname in ci.yml ([e01a38b](https://github.com/armiiller/deferred_request/commit/e01a38bd3012256946ee1200206ef0c623e15cf6))
* serialize syntax ([f407815](https://github.com/armiiller/deferred_request/commit/f40781538e638fe95877eda72d2bfc5abed431e8))
* standardrb ([9422ad1](https://github.com/armiiller/deferred_request/commit/9422ad1d9275ad4bf0cbc31e26c08cdb1e962bc3))
