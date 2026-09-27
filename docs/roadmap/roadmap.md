# ReDrive Roadmap

> This roadmap describes the development of ReDrive from its current state to a full MVP and beyond.
>
> The roadmap is not a hard commitment to deadlines. It's meant to understand the development direction, priorities, and task order.

---

## Legend

|Label|Meaning|
|---|---|
|`[x]`|Task completed|
|`[ ]`|Task planned|
|`MVP`|Required for the first full version|
|`Post-MVP`|Can be done after the first release|
|`Future`|Future idea|

---

# Phase 0. Current Project Baseline

This phase reflects what is already the foundation of the project or is in the current implementation.

## UI & Base Structure

- [x] Create Flutter project
- [x] Configure basic app structure
- [x] Add main screen
- [x] Add bottom navigation
- [x] Add basic visual styling
- [x] Add vehicle data cards
- [x] Separate UI into reusable widgets
- [x] Add demo mode for displaying test data without a car

## Bluetooth & Connection

- [x] Implement basic Bluetooth functionality
- [x] Add Bluetooth permission handling
- [x] Add Bluetooth device discovery
- [x] Add connection to selected Bluetooth adapter
- [x] Add connection cancellation handling
- [x] Add basic error handling for connections
- [x] Add reconnect logic
- [x] Add reconnect banner to UI

## OBD & ELM327

- [x] Add basic OBD data model
- [x] Add OBD connection abstraction
- [x] Add Bluetooth implementation of OBD connection
- [x] Add mock/demo OBD connection
- [x] Add initial ELM327 initialization
- [x] Add basic sensor polling
- [x] Add reading of basic values: speed, RPM, coolant temp, voltage

---

# Phase 1. Clean Up OBD Architecture

**Status:** MVP  
**Goal:** Remove excessive responsibility from `ObdProvider` and prepare the project for Wi-Fi, USB, error handling, Garage, and future extensions.

`ObdProvider` should not contain all business logic. Its job is to provide ready state to the UI, not to handle ELM commands, PID parsing, or diagnostics itself.

## Separation of Concerns

- [x] Split the current `ObdProvider` into smaller parts
- [x] Leave only UI-needed state in `ObdProvider`
- [x] Extract ELM command sending/response handling to a separate service
- [x] Extract PID response parsing to a separate class
- [x] Extract polling logic to a separate controller or service
- [ ] Extract OBD/ELM error handling into dedicated error types
- [ ] Remove logic duplication between Bluetooth, demo mode, and future connection types

## ELM327 Core

- [x] Create `ElmClient`
- [x] Create `ElmCommandQueue`
- [x] Ensure only one command executes at a time
- [x] Create a single place where `\r` is appended to commands
- [x] Add proper prompt `>` waiting
- [x] Add command timeout
- [x] Handle `NO DATA`, `STOPPED`, `SEARCHING`, `UNABLE TO CONNECT` responses
- [ ] Add raw command/response logging for debugging
- [ ] Add safe buffer clearing on disconnect/reconnect

## PID Core

- [x] Create `PidDefinition` model
- [x] Create `PidRegistry`
- [x] Create `PidDecoder`
- [x] Move standard PIDs to a separate list/registry
- [x] Add unit tests for basic PID formulas
- [ ] Add support for different units of measurement
- [ ] Add PID categories: engine, vehicle, fuel, temperature, diagnostic

```text
UI
  ↓
Provider
  ↓
ObdSession / ObdService
  ↓
ElmClient
  ↓
ObdConnection / Transport
  ↓
Bluetooth / Wi-Fi / USB / Mock (demo)
```


- [x] Add unit tests for `ElmCommandQueue` (sequencing, timeouts) 
- [x] Add unit tests for raw ELM327 response parsing (OK, NO DATA, SEARCHING)
- [x] Add unit tests for PID calculation formulas
- [ ] Add tests for proper buffer clearing on reconnection

---

# Phase 2. Wi-Fi Connection

**Status:** MVP / After basic architecture cleanup  
**Goal:** Add connection to Wi-Fi ELM327 adapters via TCP socket.

Do Wi-Fi after basic OBD logic separation to avoid embedding Wi-Fi into an already overloaded `ObdProvider`.

## Wi-Fi Transport

- [ ] Create Wi-Fi transport / connection class
- [ ] Add connection via IP and port
- [ ] Add manual IP and port input fields
- [ ] Add default values for typical Wi-Fi ELM327 adapters
- [ ] Add adapter availability check
- [ ] Add connection timeout
- [ ] Add TCP connection loss handling
- [ ] Add Wi-Fi reconnect logic
- [ ] Add last used Wi-Fi adapter persistence
- [ ] Add Wi-Fi UI states: idle, connecting, connected, failed

## Wi-Fi Integration into App

- [ ] Add connection type tab/switch: Bluetooth / Wi-Fi / USB
- [ ] Create common connection interface for different transport types
- [ ] Ensure ELM initialization works identically over Bluetooth and Wi-Fi
- [ ] Test polling over Wi-Fi
- [ ] Test reading basic PIDs over Wi-Fi

---
- [ ] Add integration tests for auto-reconnect logic 
- [ ] Add mock tests for simulating TCP connection loss 
- [ ] Add tests for permission error handling (Bluetooth/USB permissions)

---

# Phase 3. USB Connection

**Status:** Post-MVP or late MVP  
**Goal:** Add a more stable connection method via USB adapters.

USB can be the most stable option, but do it after Bluetooth and Wi-Fi if the project primarily targets mobile use.

## USB Transport

- [ ] Research available Flutter packages for USB serial
- [ ] Create USB transport / connection class
- [ ] Add USB permission requests
- [ ] Add discovered USB devices list
- [ ] Add connection to USB ELM327 adapter
- [ ] Add disconnect
- [ ] Add reconnect
- [ ] Add last used USB adapter persistence
- [ ] Test ELM initialization over USB
- [ ] Test polling basic PIDs over USB

---

# Phase 4. Live Dashboard & Sensor Reading

**Status:** MVP  
**Goal:** Make the sensors page useful and convenient for the average driver.

A driver doesn't need dozens of small parameters on one screen while driving. They need large, clear, and quickly readable data.

## Polling & Performance

- [ ] Split sensors by update priority
- [ ] Poll speed, RPM, and throttle frequently
- [ ] Poll temperature and fuel-related data less frequently
- [ ] Don't poll sensors not displayed on the current screen
- [ ] Pause polling when navigating to pages where live data isn't needed
- [ ] Optimize UI rebuilds

## Basic Sensors for MVP

- [x] Vehicle speed
- [x] Engine RPM
- [x] Coolant temperature
- [x] Adapter/battery voltage
- [ ] Throttle position
- [ ] Engine load
- [ ] Intake air temperature
- [ ] Mass air flow
- [ ] Fuel level (if supported by vehicle)
- [ ] Short-term fuel trim
- [ ] Long-term fuel trim

## UI Dashboard

- [ ] Create large cards for main parameters
- [ ] Add compact sensor list mode
- [ ] Add large speedometer/gauge mode
- [ ] Add visual highlighting for important parameters
- [ ] Add "sensor not supported by vehicle" state
- [ ] Add "no data" state
- [ ] Add selectable displayed sensors
- [ ] Add simple graphs for selected parameters
- [ ] Add landscape mode for in-car use\


- [ ] Add performance tests (check for redundant rebuilds during polling) 
- [ ] Add tests for sensor polling priority switching logic

---

# Phase 5. Reading & Clearing Fault Codes

**Status:** MVP  
**Goal:** Provide basic vehicle diagnostics.

The fault codes page is a key feature of any OBD2 app. The user shouldn't just see a code — they should understand what it roughly means and what to check next.

## DTC Core

- [ ] Create `DtcCode` model
- [ ] Create `DtcDecoder`
- [ ] Create `DtcService`
- [ ] Add reading stored codes via Mode `03`
- [ ] Add reading pending errors via Mode `07`
- [ ] Add reading permanent errors via Mode `0A`
- [ ] Handle "no errors" case
- [ ] Handle invalid responses
- [ ] Add basic DTC description database

## DTC UI

- [ ] Create fault codes reading page
- [ ] Split errors into stored, pending, permanent
- [ ] Show error code
- [ ] Show brief error description
- [ ] Show possible causes (if known)
- [ ] Show warning that the app doesn't replace full professional diagnostics
- [ ] Add rescan button
- [ ] Add empty state (no errors)
- [ ] Add loading state during scanning
- [ ] Add error state for communication issues

## Clearing Fault Codes

- [ ] Add clear codes command via Mode `04`
- [ ] Add mandatory confirmation before clearing
- [ ] Explain to user that clearing may remove diagnostic information
- [ ] Rescan codes after clearing
- [ ] Save error history before clearing

## Freeze Frame

- [ ] Add freeze frame data reading
- [ ] Show vehicle parameters at the moment the error occurred
- [ ] Link freeze frame to specific error when possible
- [ ] Add freeze frame explanation for average users


- [ ] Add unit tests for `DtcDecoder` (hex to P/C/B/U code conversion) 
- [ ] Add tests for multi-line response parsing (Mode 03/07/0A)

---

# Phase 6. Garage / Vehicle Selection

**Status:** MVP  
**Goal:** Allow user to select and store vehicles.

In the first phase, Garage should be simple. No need for a complex vehicle database initially. Just store a vehicle profile and associated data.

## Vehicle Profile.

- [ ] Create `VehicleProfile` model
- [ ] Add vehicle ID
- [ ] Add vehicle name (user-assigned)
- [ ] Add make
- [ ] Add model
- [ ] Add year
- [ ] Add VIN
- [ ] Add fuel type (if needed)
- [ ] Add user notes
- [ ] Add last used adapter
- [ ] Add last known protocol

## Garage UI

- [ ] Create Garage page
- [ ] Add vehicle list
- [ ] Add create new vehicle
- [ ] Add edit vehicle
- [ ] Add delete vehicle
- [ ] Add select active vehicle
- [ ] Show active vehicle on the main screen
- [ ] Add empty state (no vehicles yet)

## Vehicle Data

- [ ] Add VIN reading via OBD2 (if supported)
- [ ] Store error history per vehicle
- [ ] Store supported PIDs per vehicle
- [ ] Store dashboard settings per vehicle

---

# Phase 7. App Settings

**Status:** MVP  
**Goal:** Give user basic control over app behavior.

## Core Settings

- [ ] Add Settings page
- [ ] Add demo mode toggle
- [ ] Add speed unit selection: km/h / mph
- [ ] Add temperature unit selection: °C / °F
- [ ] Add polling frequency setting
- [ ] Add auto reconnect toggle
- [ ] Add theme selection (if needed)
- [ ] Add reset app settings
- [ ] Add accent color selection

## Developer Settings

- [ ] Add developer mode toggle
- [ ] Add raw OBD log viewer
- [ ] Add copy raw logs
- [ ] Show last sent command
- [ ] Show last raw response
- [ ] Show adapter information
- [ ] Show current OBD protocol

---

# Phase 8. ReDrive Packs

**Status:** Post-MVP  
**Goal:** Build a safe extension system for vehicle-specific data without executing third-party code.

ReDrive Packs are not plugins with executable code. They are data packages that describe additional PIDs, formulas, dashboard presets, DTC descriptions, and tips for specific vehicles.

## Core Concept

- [ ] Document ReDrive Packs concept
- [ ] Make clear that early pack versions work in read-only mode only
- [ ] Disallow arbitrary write commands in early pack versions
- [ ] Disallow coding/adaptation via packs in early stage
- [ ] Split packs by safety level

## Pack Schema

- [ ] Create `manifest.json` schema
- [ ] Create `pids.json` schema
- [ ] Create `dashboard.json` schema
- [ ] Create `dtc.json` schema
- [ ] Add pack schema versioning
- [ ] Add minimum app version required for pack
- [ ] Add pack compatibility validation

## Pack Loader

- [ ] Create `PackManifest`
- [ ] Create `ReDrivePack`
- [ ] Create `PackLoader`
- [ ] Create `PackValidator`
- [ ] Load standard OBD2 pack from assets
- [ ] Add PIDs from pack to `PidRegistry`
- [ ] Add DTC descriptions from pack to diagnostics
- [ ] Add dashboard presets from pack to UI

## Import & Community

- [ ] Add `.redrivepack` file import
- [ ] Validate pack before installation
- [ ] Show user exactly what the pack adds
- [ ] Show list of installed packs
- [ ] Remove installed pack
- [ ] Add example vehicle-specific pack
- [ ] Add contributor documentation for creating packs
- [ ] Future: add community registry via GitHub


- [ ] Add tests for `PackValidator` (JSON schema validation)
- [ ] Add tests for pack versioning and incompatibility handling
---

# Phase 9. Logs, Replay & Debugging

**Status:** Post-MVP  
**Goal:** Simplify bug hunting and help contributors test the app without constant access to a vehicle.

## Raw Logs

- [ ] Log sent commands
- [ ] Log adapter responses
- [ ] Log response time
- [ ] Log timeout errors
- [ ] Log reconnect events
- [ ] Add log export
- [ ] Warn user about possible VIN or personal data in logs

## OBD Replay

- [ ] Create OBD replay log format
- [ ] Add OBD session recording
- [ ] Add OBD session playback
- [ ] Use replay for demo mode
- [ ] Use replay for bug testing
- [ ] Add sample logs to repository without personal data

## Adapter Benchmark

- [ ] Measure average adapter response time
- [ ] Count timeouts
- [ ] Count successful PID requests per second
- [ ] Show connection quality
- [ ] Show current protocol
- [ ] Show adapter version (if available)

---

# Phase 10. Long-term Development

**Status:** Future  
**Goal:** Extend ReDrive only after a stable MVP.

## Enhanced Diagnostics

- [ ] Improved DTC descriptions
- [ ] Symptom-based diagnostic hints
- [ ] Error history per vehicle
- [ ] Diagnostic report export
- [ ] Freeze frame comparison
- [ ] Possible cause hints

## Trip Logging

- [ ] Trip recording
- [ ] Trip history
- [ ] Parameter graphs per trip
- [ ] Trip data export
- [ ] Approximate fuel consumption calculation (if possible)

## Vehicle-specific Extensions

- [ ] Vehicle-specific packs
- [ ] Engine-specific packs
- [ ] Diesel vehicle packs
- [ ] Support for extended PIDs
- [ ] Community-maintained packs

## Service Functions

These functions are not part of MVP and require careful implementation.

- [ ] Service reminders
- [ ] Read-only UDS experiments
- [ ] Service procedures only after risk assessment
- [ ] Backup before any changes
- [ ] Rollback mechanism (if possible)
- [ ] Strict user warnings
- [ ] Support only verified vehicles

## Coding / Adaptations

Coding and adaptations should not be an early feature.

- [ ] Research UDS / ISO-TP
- [ ] Research vehicle-specific diagnostics
- [ ] Research security access and risks
- [ ] Develop safety model
- [ ] Add read-only mode for exploring blocks
- [ ] Add current values backup
- [ ] Add strict vehicle compatibility
- [ ] Add coding only for verified scenarios