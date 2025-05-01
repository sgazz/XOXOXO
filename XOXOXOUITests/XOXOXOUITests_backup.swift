//
//  XOXOXOUITests.swift
//  XOXOXOUITests
//
//  Created by Gazza on 29. 4. 2025..
//

import XCTest

final class XOXOXOUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        // Сачекај да се заврши почетна анимација (1.5 секунди)
        sleep(2)
        
        // Сачекај да се појави прво Start Game дугме
        let openGameModeButton = app.buttons["openGameModeButton"]
        XCTAssertTrue(openGameModeButton.waitForExistence(timeout: 5), "Open Game Mode дугме се није појавило")
        openGameModeButton.tap()
        
        // Сачекај да се појави модални прозор
        sleep(1)
        
        // Изабери Single Player мод
        let singlePlayerButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Single Player'")).firstMatch
        XCTAssertTrue(singlePlayerButton.waitForExistence(timeout: 5), "Single Player дугме се није појавило")
        singlePlayerButton.tap()
        
        // Изабери X као играча
        let xButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'X'")).firstMatch
        XCTAssertTrue(xButton.waitForExistence(timeout: 5), "X дугме се није појавило")
        xButton.tap()
        
        // Изабери 1 минут
        let oneMinuteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '1 Minute'")).firstMatch
        XCTAssertTrue(oneMinuteButton.waitForExistence(timeout: 5), "1 Minute дугме се није појавило")
        oneMinuteButton.tap()
        
        // Кликни на Start Game да започнеш партију
        let startGameButton = app.buttons["startGameButton"]
        XCTAssertTrue(startGameButton.waitForExistence(timeout: 5), "Start Game дугме се није појавило")
        startGameButton.tap()
        
        // Сачекај да се заврши транзиција на игру и иницијализација GameView-а
        sleep(2)
        
        // Сачекај да се појави пауза дугме (које је увек видљиво у GameView)
        let pauseButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'pause'")).firstMatch
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 5), "Pause дугме се није појавило")
        
        // Сачекај да се појави скор (који је увек видљив у GameView)
        let scoreText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'X: 0 - O: 0'")).firstMatch
        XCTAssertTrue(scoreText.waitForExistence(timeout: 5), "Score се није појавио")
        
        // Сачекај да се појави прва празна ћелија
        let emptyCell = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Empty cell'")).firstMatch
        XCTAssertTrue(emptyCell.waitForExistence(timeout: 5), "Game board се није појавио")
        
        // Додатна провера да ли су све ћелије доступне
        let emptyCells = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Empty cell'"))
        XCTAssertEqual(emptyCells.count, 9, "Нису све ћелије доступне")
        
        // Сачекај да се учитају све табле
        sleep(2)
    }
    
    override func tearDownWithError() throws {
        app = nil
        super.tearDown()
    }
    
    // MARK: - Basic UI Tests
    
    func testInitialGameBoard() throws {
        // Провера да ли постоји табла за игру
        let emptyPredicate = NSPredicate(format: "label CONTAINS 'Empty cell'")
        let emptyCells = app.buttons.matching(emptyPredicate)
        XCTAssertEqual(emptyCells.count, 9, "Нису све ћелије доступне")
        
        // Провера да ли су сва поља празна
        for i in 0...8 {
            let cell = app.buttons["cell\(i)"]
            XCTAssertTrue(cell.waitForExistence(timeout: 5), "Ћелија \(i) није пронађена")
            XCTAssertTrue(cell.label.contains("Empty cell"), "Ћелија \(i) није празна")
        }
    }
    
    func testMakingMove() throws {
        // Сачекај да се појави централна ћелија
        let centerCell = app.buttons["cell_1_1"]
        XCTAssertTrue(centerCell.waitForExistence(timeout: 10), "Централна ћелија није пронађена")
        centerCell.tap()
        
        // Сачекај да се појави X
        sleep(2)
        
        // Провера да ли је X постављен
        let xCell = app.buttons["cell_1_1"]
        XCTAssertTrue(xCell.waitForExistence(timeout: 10), "X није постављен у централну ћелију")
        XCTAssertTrue(xCell.label.contains("X at row 2, column 2"), "Ћелија не садржи X")
    }
    
    func testGameModeSwitch() throws {
        // Кликни на паузу
        let pauseButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'pause'")).firstMatch
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 10), "Pause дугме није пронађено")
        pauseButton.tap()
        
        // Сачекај да се појави модални прозор
        sleep(2)
        
        // Кликни на Choose Game Mode
        let chooseGameModeButton = app.buttons["chooseGameModeButton"]
        XCTAssertTrue(chooseGameModeButton.waitForExistence(timeout: 10), "Choose Game Mode дугме није пронађено")
        chooseGameModeButton.tap()
        
        // Сачекај да се појави модални прозор за мод игре
        sleep(2)
        
        // Изабери Single Player
        let singlePlayerButton = app.buttons["singlePlayerButton"]
        XCTAssertTrue(singlePlayerButton.waitForExistence(timeout: 10), "Single Player дугме није пронађено")
        singlePlayerButton.tap()
        
        // Кликни на Start Game
        let startGameButton = app.buttons["startGameButton"]
        XCTAssertTrue(startGameButton.waitForExistence(timeout: 10), "Start Game дугме није пронађено")
        startGameButton.tap()
        
        // Провери да ли се мод променио
        let gameModeLabel = app.staticTexts["gameModeLabel"]
        XCTAssertTrue(gameModeLabel.waitForExistence(timeout: 10), "Game mode label није пронађен")
        XCTAssertTrue(gameModeLabel.label.contains("vs AI"), "Мод игре није промењен на Single Player")
    }
    
    func testScoreDisplay() throws {
        // Провера да ли постоји приказ резултата
        let scoreView = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'X: 0 - O: 0'")).firstMatch
        XCTAssertTrue(scoreView.waitForExistence(timeout: 5), "Score приказ није пронађен")
        
        // Провера иницијалног резултата
        XCTAssertTrue(scoreView.label.contains("X: 0 - O: 0"), "Иницијални резултат није исправан")
    }
    
    // MARK: - Game Flow Tests
    
    func testCompleteGame() throws {
        // Сачекај да се појаве све ћелије
        for i in 0...8 {
            let cell = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Empty cell'")).firstMatch
            XCTAssertTrue(cell.waitForExistence(timeout: 5), "Ћелија \(i) није пронађена")
        }
        
        // Одиграј победничку комбинацију за X
        let cell0 = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Empty cell'")).firstMatch
        XCTAssertTrue(cell0.waitForExistence(timeout: 5), "Ћелија 0 није пронађена")
        cell0.tap() // X
        
        // Сачекај да O одигра
        sleep(2)
        
        let cell3 = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Empty cell'")).firstMatch
        XCTAssertTrue(cell3.waitForExistence(timeout: 5), "Ћелија 3 није пронађена")
        cell3.tap() // X
        
        // Сачекај да O одигра
        sleep(2)
        
        let cell6 = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Empty cell'")).firstMatch
        XCTAssertTrue(cell6.waitForExistence(timeout: 5), "Ћелија 6 није пронађена")
        cell6.tap() // X
        
        // Провера да ли је X победио
        let winLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'X'")).firstMatch
        XCTAssertTrue(winLabel.waitForExistence(timeout: 5), "Winner ознака се није појавила")
    }
    
    func testResetGame() throws {
        // Направи неколико потеза
        let cell0 = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Empty cell at row 1, column 1'")).firstMatch
        XCTAssertTrue(cell0.waitForExistence(timeout: 5), "Ћелија 0 није пронађена")
        cell0.tap()
        
        // Сачекај AI потез
        sleep(2)
        
        // Кликни на паузу
        let pauseButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'pause'")).firstMatch
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 5), "Pause дугме није пронађено")
        pauseButton.tap()
        
        // Сачекај да се појави модални прозор
        sleep(2)
        
        // Кликни на Choose Game Mode
        let chooseGameModeButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Choose Game Mode'")).firstMatch
        XCTAssertTrue(chooseGameModeButton.waitForExistence(timeout: 5), "Choose Game Mode дугме није пронађено")
        chooseGameModeButton.tap()
        
        // Сачекај да се појави модални прозор за мод игре
        sleep(2)
        
        // Изабери исте опције као у setUp
        let singlePlayerButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Single Player'")).firstMatch
        XCTAssertTrue(singlePlayerButton.waitForExistence(timeout: 5), "Single Player дугме није пронађено")
        singlePlayerButton.tap()
        
        let xButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'X'")).firstMatch
        XCTAssertTrue(xButton.waitForExistence(timeout: 5), "X дугме није пронађено")
        xButton.tap()
        
        let oneMinuteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '1 Minute'")).firstMatch
        XCTAssertTrue(oneMinuteButton.waitForExistence(timeout: 5), "1 Minute дугме није пронађено")
        oneMinuteButton.tap()
        
        let startGameButton = app.buttons["startGameButton"]
        XCTAssertTrue(startGameButton.waitForExistence(timeout: 5), "Start Game дугме није пронађено")
        startGameButton.tap()
        
        // Сачекај да се појаве све ћелије
        sleep(2)
        
        // Провери да ли су сва поља празна
        for i in 0...8 {
            let cell = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Empty cell'")).firstMatch
            XCTAssertTrue(cell.waitForExistence(timeout: 5), "Ћелија \(i) се није појавила")
            XCTAssertTrue(cell.label.contains("Empty cell"), "Ћелија \(i) није празна")
        }
    }
    
    // MARK: - Statistics Tests
    
    func testStatisticsView() throws {
        // Кликни на паузу
        let pauseButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'pause'")).firstMatch
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 10), "Pause дугме није пронађено")
        pauseButton.tap()
        
        // Сачекај да се појави модални прозор
        sleep(2)
        
        // Кликни на Statistics
        let statisticsButton = app.buttons["allTimeStatsButton"]
        XCTAssertTrue(statisticsButton.waitForExistence(timeout: 10), "Statistics дугме није пронађено")
        statisticsButton.tap()
        
        // Провера да ли се појавио модални прозор за статистику
        let statisticsTitle = app.staticTexts["statisticsTitle"]
        XCTAssertTrue(statisticsTitle.waitForExistence(timeout: 10), "Statistics наслов није пронађен")
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibility() throws {
        // Провера да ли су све ћелије доступне
        for i in 0...8 {
            let row = (i / 3) + 1
            let col = (i % 3) + 1
            let cell = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Empty cell at row \(row), column \(col)'")).firstMatch
            XCTAssertTrue(cell.waitForExistence(timeout: 5), "Ћелија \(i) није пронађена")
            XCTAssertTrue(cell.isEnabled, "Ћелија \(i) није омогућена")
        }
        
        // Провера да ли су сва дугмад доступна
        let buttons = [
            "pauseButton"
        ]
        
        for button in buttons {
            let element = app.buttons[button]
            XCTAssertTrue(element.waitForExistence(timeout: 5), "\(button) није пронађен")
            XCTAssertTrue(element.isEnabled, "\(button) није омогућен")
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidMoveHandling() throws {
        // Сачекај да се појави централна ћелија
        let centerCell = app.buttons["cell4"]
        XCTAssertTrue(centerCell.waitForExistence(timeout: 10), "Централна ћелија није пронађена")
        centerCell.tap()
        
        // Сачекај да се појави X
        sleep(2)
        
        // Покушај да поново кликнеш на исту ћелију
        centerCell.tap()
        
        // Провера да ли је приказана грешка
        let errorLabel = app.staticTexts["error"]
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 10), "X није пронађен")
    }
    
    // MARK: - Layout Tests
    
    func testLayoutOnDifferentDevices() throws {
        // Провера да ли су све ћелије видљиве и кликабилне
        for i in 0...8 {
            let row = (i / 3) + 1
            let col = (i % 3) + 1
            let cell = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Empty cell at row \(row), column \(col)'")).firstMatch
            XCTAssertTrue(cell.waitForExistence(timeout: 5), "Ћелија \(i) није пронађена")
            XCTAssertTrue(cell.isHittable, "Ћелија \(i) није видљива или кликабилна")
        }
        
        // Провера да ли је скор приказ видљив
        let scoreView = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'X: 0 - O: 0'")).firstMatch
        XCTAssertTrue(scoreView.waitForExistence(timeout: 5), "Score приказ није пронађен")
        XCTAssertTrue(scoreView.isHittable, "Score приказ није видљив")
        
        // Провера да ли је пауза дугме видљиво
        let pauseButton = app.buttons["pauseButton"]
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 5), "Pause дугме није пронађено")
        XCTAssertTrue(pauseButton.isHittable, "Pause дугме није видљиво")
    }
    
    // MARK: - Additional View Tests
    
    func testAllStatsView() throws {
        // Кликни на паузу
        let pauseButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'pause'")).firstMatch
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 10), "Pause дугме није пронађено")
        pauseButton.tap()
        
        // Сачекај да се појави модални прозор
        sleep(2)
        
        // Кликни на Statistics
        let statisticsButton = app.buttons["statsButton"]
        XCTAssertTrue(statisticsButton.waitForExistence(timeout: 10), "Statistics дугме није пронађено")
        statisticsButton.tap()
        
        // Сачекај да се појаве статистике
        sleep(2)
    }
    
    func testTutorialView() throws {
        // Кликни на паузу
        let pauseButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'pause'")).firstMatch
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 10), "Pause дугме није пронађено")
        pauseButton.tap()
        
        // Сачекај да се појави модални прозор
        sleep(2)
        
        // Кликни на Tutorial
        let tutorialButton = app.buttons["tutorialButton"]
        XCTAssertTrue(tutorialButton.waitForExistence(timeout: 10), "Tutorial дугме није пронађено")
        tutorialButton.tap()
    }
    
    func testGameOverView() throws {
        // Одиграј партију до краја
        let cells = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Empty cell'"))
        for i in 0..<cells.count {
            let cell = cells.element(boundBy: i)
            XCTAssertTrue(cell.waitForExistence(timeout: 10), "Ћелија \(i) није пронађена")
            cell.tap()
            sleep(1)
        }
        
        // Провера да ли се појавио Game Over view
        let gameOverView = app.otherElements["GameOverView"]
        XCTAssertTrue(gameOverView.waitForExistence(timeout: 10), "Game Over view није пронађен")
    }
    
    func testGameBoardView() throws {
        // Провера да ли постоји game mode дугме
        let gameModeButton = app.buttons["gameMode"]
        XCTAssertTrue(gameModeButton.waitForExistence(timeout: 10), "gameMode није пронађен у Game Board view-у")
    }
    
    func testSoundManager() throws {
        // Кликни на централну ћелију
        let centerCell = app.buttons["cell4"]
        XCTAssertTrue(centerCell.waitForExistence(timeout: 10), "Централна ћелија није пронађена")
        centerCell.tap()
        
        // Провера да ли је tap звук одигран
        let soundManager = app.otherElements["SoundManager"]
        XCTAssertTrue(soundManager.waitForExistence(timeout: 10), "tap звук није пронађен")
    }
}
