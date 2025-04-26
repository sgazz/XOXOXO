# XOXOXO

An unusual version of Tic-Tac-Toe written in SwiftUI.

## Features

- 8 game boards in a row
- Two game modes:
  - Play against AI opponent
  - Play against another player
- Symbol selection (X or O)
- Game duration selection:
  - 1 minute
  - 3 minutes
  - 5 minutes
- Visual indication of active board
- Automatic switching to next board
- Winner check for each board
- Modern metallic design
- Animations and visual effects
- Interaction sounds
- iPad and iPhone support
- Support for different screen orientations

## Project Structure

- `Game/` - Game Logic
  - `GameLogic.swift` - Main game logic
  - `TicTacToeAI.swift` - AI opponent implementation
  - `GameTimer.swift` - Game timer implementation
- `Views/` - UI Components
  - `BoardView.swift` - Board display components
  - `GameModeModalView.swift` - Game mode selection modal
  - `TutorialView.swift` - Tutorial screens
  - `GameOverView.swift` - Game over screen
  - `SplashView.swift` - Splash screen
- `Theme/` - Visual Design
  - `Theme.swift` - Color schemes and styles
- `Utils/` - Utilities
  - `SoundManager.swift` - Sound effects management
  - `DeviceLayout.swift` - Device-specific layouts

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository
```bash
git clone https://github.com/sgazz/XOXOXO.git
```

2. Open `XOXOXO.xcodeproj` in Xcode
3. Run the project (⌘R)

## License

MIT License 