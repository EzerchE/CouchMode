# Changelog

All notable changes to this project are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-05-23

### Changed
- Replaced the 1-second polling loop with an **event-driven** architecture: a
  message-only window listens for device interface arrival/removal notifications
  (`WM_DEVICECHANGE` via `RegisterDeviceNotification`). Idle CPU usage is now zero;
  the app only does work when a controller is connected or disconnected.
- A short debounce coalesces bursts of device messages and gives XInput time to
  recognise a freshly powered controller.

### Removed
- The configurable poll interval setting (no longer applicable).

## [1.0.0] - 2026-05-23

### Added
- Automatic switching of the Windows 11 Xbox full screen experience based on
  Xbox controller connection state.
- XInput-based controller detection (wired, wireless dongle, Bluetooth).
- Monitor-relative Xbox mode detection that works on any resolution and
  multi-monitor setup.
- System tray interface with pause/resume.
- Settings dialog: enable-on-connect, disable-on-disconnect, start with Windows,
  and configurable poll interval.
- Activity logging to `%AppData%\AutoXboxMode\app.log`.
