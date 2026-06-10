# Vaani

Vaani is a Swift Student Challenge prototype about preserving a grandparent's voice as private family memory cards.

The demo is intentionally offline, deterministic, and small. It does not use WhisperKit, network calls, cloud sync, or runtime downloads. The experience simulates an elder memory being captured, turns it into a card, and places it in a family archive.

## Run

Open `Vaani.xcodeproj` in Xcode and run the `Vaani` scheme on an iPhone or iPad simulator. This native iOS project points at the same SwiftUI source files and produces a proper `Vaani.app` bundle.

The `Package.swift` file is kept for source portability, but the Xcode project is the recommended way to run the prototype in the simulator.

## Challenge Notes

- Designed for a 3-minute judging experience.
- Works without microphone permission because the transcript path is simulated.
- Uses only Apple-native frameworks available through SwiftUI/Foundation.
- Full Indian-language transcription is reserved for a later production app.
