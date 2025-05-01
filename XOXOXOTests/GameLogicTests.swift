import XCTest
@testable import XOXOXO

class GameLogicTests: XCTestCase {
    var gameLogic: GameLogic!
    
    override func setUp() {
        super.setUp()
        gameLogic = GameLogic(gameMode: .aiOpponent)
    }
    
    override func tearDown() {
        gameLogic = nil
        super.tearDown()
    }
    
    // MARK: - AI Game Statistics Tests
    
    // Test za proveru statistike kada X pobedi protiv AI
    func testXWinsAgainstAI() {
        makeWinningMovesForX()
        
        XCTAssertEqual(gameLogic.playerStats.x.vsAIGames, 1)
        XCTAssertEqual(gameLogic.playerStats.x.vsAIWins, 1)
        XCTAssertEqual(gameLogic.playerStats.o.vsAIGames, 1)
        XCTAssertEqual(gameLogic.playerStats.o.vsAILosses, 1)
    }
    
    // Test za proveru statistike kada O pobedi protiv AI
    func testOWinsAgainstAI() {
        makeWinningMovesForO()
        
        XCTAssertEqual(gameLogic.playerStats.o.vsAIGames, 1)
        XCTAssertEqual(gameLogic.playerStats.o.vsAIWins, 1)
        XCTAssertEqual(gameLogic.playerStats.x.vsAIGames, 1)
        XCTAssertEqual(gameLogic.playerStats.x.vsAILosses, 1)
    }
    
    // Test za proveru statistike kada je remi protiv AI
    func testDrawAgainstAI() {
        makeDrawMoves()
        
        XCTAssertEqual(gameLogic.playerStats.x.vsAIGames, 1)
        XCTAssertEqual(gameLogic.playerStats.x.vsAIDraws, 1)
        XCTAssertEqual(gameLogic.playerStats.o.vsAIGames, 1)
        XCTAssertEqual(gameLogic.playerStats.o.vsAIDraws, 1)
    }
    
    // MARK: - Time Statistics Tests
    
    func testTimeStatistics() {
        makeGameWithDifferentMoveTimes()
        
        XCTAssertGreaterThan(gameLogic.playerStats.x.totalMoveTime, 0)
        XCTAssertGreaterThan(gameLogic.playerStats.x.averageMoveTime, 0)
        XCTAssertGreaterThan(gameLogic.playerStats.x.fastestMove, 0)
    }
    
    // MARK: - Move Statistics Tests
    
    func testMoveStatistics() {
        makeGameWithDifferentMoves()
        
        XCTAssertGreaterThan(gameLogic.playerStats.x.totalMoves, 0)
        XCTAssertGreaterThan(gameLogic.playerStats.x.centerMoves, 0)
        XCTAssertGreaterThan(gameLogic.playerStats.x.cornerMoves, 0)
    }
    
    // MARK: - Board Statistics Tests
    
    func testBoardStatistics() {
        makeGameWithBoardWins()
        
        XCTAssertGreaterThan(gameLogic.playerStats.x.boardsWon, 0)
        XCTAssertGreaterThan(gameLogic.playerStats.x.totalBoards, 0)
        XCTAssertGreaterThan(gameLogic.playerStats.x.boardWinRate, 0)
    }
    
    // MARK: - Streak and Bonus Tests
    
    func testStreakAndBonusStatistics() {
        makeGameWithStreaksAndBonuses()
        
        XCTAssertGreaterThan(gameLogic.playerStats.x.currentWinStreak, 0)
        XCTAssertGreaterThan(gameLogic.playerStats.x.longestWinStreak, 0)
    }
    
    // MARK: - Test za proveru više uzastopnih igara
    
    func testMultipleGamesAgainstAI() {
        makeWinningMovesForX()
        gameLogic.resetBoard(0)
        makeWinningMovesForO()
        gameLogic.resetBoard(0)
        makeDrawMoves()
        
        XCTAssertEqual(gameLogic.playerStats.x.vsAIGames, 3)
        XCTAssertEqual(gameLogic.playerStats.x.vsAIWins, 1)
        XCTAssertEqual(gameLogic.playerStats.x.vsAILosses, 1)
        XCTAssertEqual(gameLogic.playerStats.x.vsAIDraws, 1)
        
        XCTAssertEqual(gameLogic.playerStats.o.vsAIGames, 3)
        XCTAssertEqual(gameLogic.playerStats.o.vsAIWins, 1)
        XCTAssertEqual(gameLogic.playerStats.o.vsAILosses, 1)
        XCTAssertEqual(gameLogic.playerStats.o.vsAIDraws, 1)
    }
    
    // MARK: - Game Mode Tests
    
    func testGameModeSwitch() {
        // Prvo igramo protiv AI
        makeWinningMovesForX()
        
        // Prelazimo na Player vs Player mod
        gameLogic.setGameMode(.playerVsPlayer)
        
        // Igramo jednu igru protiv igrača
        makeWinningMovesForO()
        
        // Proveravamo statistiku
        XCTAssertEqual(gameLogic.playerStats.x.vsAIGames, 1, "X treba da ima 1 igru protiv AI")
        XCTAssertEqual(gameLogic.playerStats.o.vsAIGames, 1, "O treba da ima 1 igru protiv AI")
    }
    
    // MARK: - Comeback Tests
    
    func testComebackWin() {
        makeWinningMovesForO()
        gameLogic.resetBoard(0)
        makeWinningMovesForX()
        gameLogic.resetBoard(0)
        makeWinningMovesForX()
        
        XCTAssertEqual(gameLogic.playerStats.x.comebackWins, 1)
        XCTAssertGreaterThan(gameLogic.playerStats.x.currentWinStreak, 1)
    }
    
    // MARK: - Board Position Tests
    
    func testBoardPositionStats() {
        _ = gameLogic.makeMove(at: 4, in: 0) // X centar
        _ = gameLogic.makeMove(at: 0, in: 0) // O ugao
        _ = gameLogic.makeMove(at: 8, in: 0) // X ugao
        _ = gameLogic.makeMove(at: 2, in: 0) // O ugao
        _ = gameLogic.makeMove(at: 6, in: 0) // X ugao
        
        XCTAssertEqual(gameLogic.playerStats.x.centerMoves, 1)
        XCTAssertEqual(gameLogic.playerStats.x.cornerMoves, 2)
        XCTAssertEqual(gameLogic.playerStats.o.cornerMoves, 2)
    }
    
    // MARK: - Performance Tests
    
    func testGamePerformance() {
        gameLogic = GameLogic(gameMode: .aiOpponent)
        
        measure {
            // Merimo vreme potrebno za kompletnu igru
            makeWinningMovesForX()
        }
    }
    
    // MARK: - Edge Case Tests
    
    func testInvalidMoves() {
        _ = gameLogic.makeMove(at: 4, in: 0)
        _ = gameLogic.makeMove(at: 4, in: 0)
        
        XCTAssertEqual(gameLogic.boards[0][4], "X")
        XCTAssertEqual(gameLogic.playerStats.x.totalMoves, 1)
    }
    
    func testBoardBoundaries() {
        // Validan potez
        _ = gameLogic.makeMove(at: 4, in: 0)
        
        // Nevažeći potezi - van granica pozicija
        _ = gameLogic.makeMove(at: 9, in: 0)  // Pozicija > 8
        _ = gameLogic.makeMove(at: -1, in: 0) // Negativna pozicija
        
        // Nevažeći potezi - van granica table
        _ = gameLogic.makeMove(at: 0, in: -1)  // Negativan indeks table
        _ = gameLogic.makeMove(at: 0, in: 7)   // Maksimalan validan indeks table
        _ = gameLogic.makeMove(at: 0, in: 8)   // Indeks table = BOARD_COUNT
        
        // Provera da je samo prvi potez registrovan
        XCTAssertEqual(gameLogic.boards[0][4], "X", "Centar prve table treba da bude X")
        XCTAssertEqual(gameLogic.playerStats.x.totalMoves, 1, "Samo jedan potez treba da bude registrovan")
        
        // Provera da su ostala polja prazna
        for i in 0..<9 where i != 4 {
            XCTAssertTrue(gameLogic.boards[0][i].isEmpty, "Polje \(i) na prvoj tabli treba da bude prazno")
        }
        
        // Provera da su ostale table prazne
        for boardIndex in 1..<GameLogic.BOARD_COUNT {
            for position in 0..<9 {
                XCTAssertTrue(gameLogic.boards[boardIndex][position].isEmpty, "Polje \(position) na tabli \(boardIndex) treba da bude prazno")
            }
        }
    }
    
    // MARK: - AI Opponent Tests
    
    func testAIResponse() {
        let expectation = XCTestExpectation(description: "AI treba da odigra potez")
        
        // X igra prvi potez
        _ = gameLogic.makeMove(at: 4, in: 0)
        
        // Čekamo AI odgovor
        gameLogic.makeAIMove(in: 0) {
            // Proveravamo da li je AI odigrao potez
            let aiMoved = self.gameLogic.boards[0].contains("O")
            XCTAssertTrue(aiMoved, "AI treba da odigra potez")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Game State Tests
    
    func testGameStateAfterWin() {
        // Igramo do pobede X
        _ = gameLogic.makeMove(at: 0, in: 0) // X
        _ = gameLogic.makeMove(at: 3, in: 0) // O
        _ = gameLogic.makeMove(at: 1, in: 0) // X
        _ = gameLogic.makeMove(at: 4, in: 0) // O
        _ = gameLogic.makeMove(at: 2, in: 0) // X - pobeda
        
        // Proveravamo stanje igre
        XCTAssertNotNil(gameLogic.checkBoardWinner(in: 0), "Treba da postoji pobednik")
        XCTAssertFalse(gameLogic.winningIndexes.isEmpty, "Treba da postoje pobedničke pozicije")
        XCTAssertGreaterThan(gameLogic.totalScore.x, 0, "X treba da ima poene")
    }
    
    // MARK: - Additional Tests
    
    func testPlayerSymbolSwitch() {
        // Proveravamo da li se trenutni igrač pravilno postavlja kada se promeni mod igre
        gameLogic.setGameMode(.playerVsPlayer)
        XCTAssertEqual(gameLogic.currentPlayer, "X", "U Player vs Player modu, prvi igrač treba da bude X")
        
        // Pravimo potez da proverimo promenu igrača
        _ = gameLogic.makeMove(at: 0, in: 0)
        XCTAssertEqual(gameLogic.currentPlayer, "O", "Nakon X poteza, treba da bude O na redu")
        
        // Prelazimo na AI mod
        gameLogic.setGameMode(.aiOpponent)
        XCTAssertEqual(gameLogic.currentPlayer, "X", "Nakon promene moda, prvi igrač treba da bude X")
        
        // Proveravamo da li AI igra kada treba
        _ = gameLogic.makeMove(at: 1, in: 0)
        XCTAssertTrue(gameLogic.isAITurn, "Nakon X poteza, AI treba da bude na redu")
    }
    
    func testResetStatistics() {
        // Prvo napravimo neke poteze
        makeWinningMovesForX()
        
        // Resetujemo samo statistiku
        gameLogic.resetStatistics()
        
        // Proveravamo da li je statistika resetovana
        XCTAssertEqual(gameLogic.playerStats.x.totalGames, 0)
        XCTAssertEqual(gameLogic.playerStats.x.vsAIGames, 0)
        XCTAssertEqual(gameLogic.playerStats.x.totalMoves, 0)
        XCTAssertEqual(gameLogic.playerStats.x.boardsWon, 0)
        XCTAssertEqual(gameLogic.playerStats.x.currentWinStreak, 0)
    }
    
    func testSimultaneousGamesOnDifferentBoards() {
        // Igramo simultano na dve table
        _ = gameLogic.makeMove(at: 0, in: 0) // X na prvoj tabli
        _ = gameLogic.makeMove(at: 4, in: 1) // O na drugoj tabli
        _ = gameLogic.makeMove(at: 1, in: 0) // X na prvoj tabli
        _ = gameLogic.makeMove(at: 0, in: 1) // O na drugoj tabli
        
        // Proveravamo stanje obe table
        XCTAssertEqual(gameLogic.boards[0][0], "X")
        XCTAssertEqual(gameLogic.boards[0][1], "X")
        XCTAssertEqual(gameLogic.boards[1][4], "O")
        XCTAssertEqual(gameLogic.boards[1][0], "O")
    }
    
    func testGameOverCondition() {
        // Igramo do pobede
        makeWinningMovesForX()
        
        // Proveravamo da li je igra završena
        XCTAssertTrue(gameLogic.checkBoardWinner(in: 0) == "X")
        
        // Pokušavamo da igramo nakon pobede
        let moveAfterWin = gameLogic.makeMove(at: 5, in: 0)
        XCTAssertFalse(moveAfterWin, "Ne bi trebalo dozvoliti poteze nakon pobede")
    }
    
    func testAIThinkingTime() {
        let expectation = XCTestExpectation(description: "AI treba da razmišlja određeno vreme")
        let startTime = Date()
        
        gameLogic.makeAIMove(in: 0, thinkingTime: 0.5) {
            let endTime = Date()
            let thinkingTime = endTime.timeIntervalSince(startTime)
            XCTAssertGreaterThanOrEqual(thinkingTime, 0.5, "AI treba da razmišlja bar 0.5 sekundi")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Helper Methods
    
    private func makeWinningMovesForX() {
        // X pobeda u prvoj tabli (dijagonala)
        _ = gameLogic.makeMove(at: 0, in: 0) // X
        _ = gameLogic.makeMove(at: 1, in: 0) // O
        _ = gameLogic.makeMove(at: 4, in: 0) // X
        _ = gameLogic.makeMove(at: 2, in: 0) // O
        _ = gameLogic.makeMove(at: 8, in: 0) // X
    }
    
    private func makeWinningMovesForO() {
        // O pobeda u prvoj tabli (horizontala)
        _ = gameLogic.makeMove(at: 3, in: 0) // X
        _ = gameLogic.makeMove(at: 0, in: 0) // O
        _ = gameLogic.makeMove(at: 4, in: 0) // X
        _ = gameLogic.makeMove(at: 1, in: 0) // O
        _ = gameLogic.makeMove(at: 8, in: 0) // X
        _ = gameLogic.makeMove(at: 2, in: 0) // O
    }
    
    private func makeDrawMoves() {
        // Remi u prvoj tabli
        _ = gameLogic.makeMove(at: 0, in: 0) // X
        _ = gameLogic.makeMove(at: 1, in: 0) // O
        _ = gameLogic.makeMove(at: 2, in: 0) // X
        _ = gameLogic.makeMove(at: 4, in: 0) // O
        _ = gameLogic.makeMove(at: 3, in: 0) // X
        _ = gameLogic.makeMove(at: 5, in: 0) // O
        _ = gameLogic.makeMove(at: 7, in: 0) // X
        _ = gameLogic.makeMove(at: 6, in: 0) // O
        _ = gameLogic.makeMove(at: 8, in: 0) // X
    }
    
    private func makeGameWithDifferentMoveTimes() {
        // Simuliramo različita vremena između poteza
        Thread.sleep(forTimeInterval: 0.5)
        _ = gameLogic.makeMove(at: 0, in: 0)
        Thread.sleep(forTimeInterval: 0.5)
        _ = gameLogic.makeMove(at: 1, in: 0)
        Thread.sleep(forTimeInterval: 0.5)
        _ = gameLogic.makeMove(at: 2, in: 0)
        
        // Čekamo da se ažurira statistika
        Thread.sleep(forTimeInterval: 0.1)
    }
    
    private func makeGameWithDifferentMoves() {
        // Centar i uglovi
        _ = gameLogic.makeMove(at: 4, in: 0) // X centar
        _ = gameLogic.makeMove(at: 0, in: 0) // O ugao
        _ = gameLogic.makeMove(at: 8, in: 0) // X ugao
        _ = gameLogic.makeMove(at: 2, in: 0) // O ugao
        _ = gameLogic.makeMove(at: 6, in: 0) // X ugao
    }
    
    private func makeGameWithBoardWins() {
        // Pobeda na prvoj tabli
        makeWinningMovesForX()
        gameLogic.resetBoard(0)
        // Pobeda na drugoj tabli
        makeWinningMovesForX()
    }
    
    private func makeGameWithStreaksAndBonuses() {
        // Niz pobeda
        makeWinningMovesForX()
        gameLogic.resetBoard(0)
        makeWinningMovesForX()
        gameLogic.resetBoard(0)
        makeWinningMovesForX()
    }
} 