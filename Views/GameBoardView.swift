            // Game mode button
            Button(action: {
                gameLogic.setGameMode(gameLogic.gameMode == .aiOpponent ? .playerVsPlayer : .aiOpponent)
            }) {
                Text(gameLogic.gameMode == .aiOpponent ? "vs AI" : "Player vs Player")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .accessibilityIdentifier("gameMode") 