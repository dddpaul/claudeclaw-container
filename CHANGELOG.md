# [1.6.0](https://github.com/paulmeier/claudeclaw-container/compare/v1.5.2...v1.6.0) (2026-05-13)


### Features

* persist npm global installs and npx cache in the appdata volume ([1786d18](https://github.com/paulmeier/claudeclaw-container/commit/1786d18735738715a901f2acd795c866559fd936))

## [1.10.0](https://github.com/dddpaul/claudeclaw-container/compare/v1.9.1...v1.10.0) (2026-05-24)


### Features

* trixie base + Chromium runtime deps for dev-browser plugin ([bf9fed9](https://github.com/dddpaul/claudeclaw-container/commit/bf9fed9eba9bb431f95f18019a520b4a43ecae34))

## [1.9.1](https://github.com/paulmeier/claudeclaw-container/compare/v1.9.0...v1.9.1) (2026-05-19)


### Bug Fixes

* move persistence env vars into Dockerfile ENV so docker exec inherits them ([dedd017](https://github.com/paulmeier/claudeclaw-container/commit/dedd01732a2021056eca42b4db6ce09281bba63a))
* move persistence env vars into Dockerfile ENV so docker exec inherits them ([495b46b](https://github.com/paulmeier/claudeclaw-container/commit/495b46b00f4e9822757b256a93f8b21c394b5c7a))

## [1.9.0](https://github.com/paulmeier/claudeclaw-container/compare/v1.8.0...v1.9.0) (2026-05-19)


### Features

* UV + pnpm support, base-image migration scripts, and startup healthcheck ([0a0b48d](https://github.com/paulmeier/claudeclaw-container/commit/0a0b48dbe0e975c6c2ca300fb8407f0aeaf71d95))


### Bug Fixes

* pnpm PATH off-by-`/bin` and drop dead pnpm-store machinery ([3c68f7b](https://github.com/paulmeier/claudeclaw-container/commit/3c68f7b2c2b90a704a7b2cf12c0677bc89d421c1))

## [1.8.0](https://github.com/paulmeier/claudeclaw-container/compare/v1.7.1...v1.8.0) (2026-05-18)


### Features

* persist pip-installed Python packages in the volume ([4dc4fd7](https://github.com/paulmeier/claudeclaw-container/commit/4dc4fd741328ce42dd3d43f3552d1e86efa0c3d7))
* persist pip-installed Python packages in the volume ([42fc51e](https://github.com/paulmeier/claudeclaw-container/commit/42fc51e28ad50367cfef6e6264dbc7568a26885f))

## [1.7.1](https://github.com/paulmeier/claudeclaw-container/compare/v1.7.0...v1.7.1) (2026-05-18)


### Bug Fixes

* install python3 to support Claude Code subprocesses ([7b85e76](https://github.com/paulmeier/claudeclaw-container/commit/7b85e76996bfc45728a95fb72c0eb8f38e6e0695))
* install python3 to support Claude Code subprocesses ([270e932](https://github.com/paulmeier/claudeclaw-container/commit/270e932e12c0ad2c43c0ec247579cacd3abebd22)), closes [#11](https://github.com/paulmeier/claudeclaw-container/issues/11)

## [1.7.0](https://github.com/paulmeier/claudeclaw-container/compare/v1.6.1...v1.7.0) (2026-05-17)


### Features

* migrate to release-please + GHCR (same pattern as plus-container) ([c86a75e](https://github.com/paulmeier/claudeclaw-container/commit/c86a75ee12aa3da227983f61d4907934bbceab95))
* migrate to release-please + GHCR (same pattern as plus-container) ([64b0594](https://github.com/paulmeier/claudeclaw-container/commit/64b0594f4d4be8d1dcac66dc69b6ccd7804cf2b7))

## [1.5.2](https://github.com/paulmeier/claudeclaw-container/compare/v1.5.1...v1.5.2) (2026-05-13)


### Bug Fixes

* set IS_SANDBOX=1 so Claude Code accepts --dangerously-skip-permissions as root ([e9e499b](https://github.com/paulmeier/claudeclaw-container/commit/e9e499bdef67b7f16c0da7065cae3fabcd6df8e9))

## [1.5.1](https://github.com/paulmeier/claudeclaw-container/compare/v1.5.0...v1.5.1) (2026-05-09)


### Bug Fixes

* publish release for Node 24 LTS upgrade ([ffeeac0](https://github.com/paulmeier/claudeclaw-container/commit/ffeeac041e17f4a8d646de64d4cc52257a8ff3c8))

# [1.5.0](https://github.com/paulmeier/claudeclaw-container/compare/v1.4.0...v1.5.0) (2026-05-09)


### Features

* support running backup.sh from inside the container ([41ca68e](https://github.com/paulmeier/claudeclaw-container/commit/41ca68ea0acbaef12b2848a230d6e94b520cc499))

# [1.4.0](https://github.com/paulmeier/claudeclaw-container/compare/v1.3.6...v1.4.0) (2026-05-09)


### Features

* restore lint and security as standalone workflows for badges ([a4f72fe](https://github.com/paulmeier/claudeclaw-container/commit/a4f72fee1393cf0736f56cee9428f9a5b8cd8e64))

## [1.3.6](https://github.com/paulmeier/claudeclaw-container/compare/v1.3.5...v1.3.6) (2026-05-09)


### Bug Fixes

* explicitly install ca-certificates in Dockerfile ([0e9b79a](https://github.com/paulmeier/claudeclaw-container/commit/0e9b79a68deca9464fe3050e2d0e42240178c579))

## [1.3.5](https://github.com/paulmeier/claudeclaw-container/compare/v1.3.4...v1.3.5) (2026-05-09)


### Bug Fixes

* set hadolint failure-threshold to error ([ad043f2](https://github.com/paulmeier/claudeclaw-container/commit/ad043f238313aa128f37289f07ada300446c3368))

## [1.3.4](https://github.com/paulmeier/claudeclaw-container/compare/v1.3.3...v1.3.4) (2026-05-09)


### Bug Fixes

* use inline ignore list for hadolint instead of config file ([5cf1c71](https://github.com/paulmeier/claudeclaw-container/commit/5cf1c71698e733588b475613ca795df9abb703bd))

## [1.3.3](https://github.com/paulmeier/claudeclaw-container/compare/v1.3.2...v1.3.3) (2026-05-09)


### Bug Fixes

* explicitly pass .hadolint.yaml config to hadolint action ([757b68b](https://github.com/paulmeier/claudeclaw-container/commit/757b68bd7025682954652af730272a6e00f53b9a))

## [1.3.2](https://github.com/paulmeier/claudeclaw-container/compare/v1.3.1...v1.3.2) (2026-05-09)


### Bug Fixes

* resolve hadolint warnings in Dockerfile ([8d54dc1](https://github.com/paulmeier/claudeclaw-container/commit/8d54dc107f1167dc028c5bf68e61fc902c1aa1ea))

## [1.3.1](https://github.com/paulmeier/claudeclaw-container/compare/v1.3.0...v1.3.1) (2026-05-09)


### Bug Fixes

* correct trivy-action version to v0.36.0 ([57b3399](https://github.com/paulmeier/claudeclaw-container/commit/57b3399c8d3bf5fe671d6ce0b08ec460b203cd98))

# [1.3.0](https://github.com/paulmeier/claudeclaw-container/compare/v1.2.0...v1.3.0) (2026-05-09)


### Features

* add Dockerfile lint, Trivy security scan, and README badges ([0991ea6](https://github.com/paulmeier/claudeclaw-container/commit/0991ea6ac050b524c6585324babbc3cd2b37086b))

# [1.2.0](https://github.com/paulmeier/claudeclaw-container/compare/v1.1.0...v1.2.0) (2026-05-09)


### Features

* add backup.sh with README docs and zsh alias instructions ([aa80b00](https://github.com/paulmeier/claudeclaw-container/commit/aa80b002603ad44d0a5f868ffdc280ceec4e1841))

# [1.1.0](https://github.com/paulmeier/claudeclaw-container/compare/v1.0.1...v1.1.0) (2026-05-09)


### Features

* add shell.sh, settings.example.json, and desktop access docs ([eb2266e](https://github.com/paulmeier/claudeclaw-container/commit/eb2266ea1d5d30e92a1d88b18ca5f2cc8df4f20d))

## [1.0.1](https://github.com/paulmeier/claudeclaw-container/compare/v1.0.0...v1.0.1) (2026-05-09)


### Bug Fixes

* remove incorrect ANTHROPIC_API_KEY requirement ([b3e8e60](https://github.com/paulmeier/claudeclaw-container/commit/b3e8e6016a39271996635e49feb5e9db90c16f57))
