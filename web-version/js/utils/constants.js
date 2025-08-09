// Game Constants
const GAME_CONFIG = {
    BOARD_COUNT: 8,
    GRID_SIZE: 3,
    CELL_COUNT: 9,
    INITIAL_TIME: 180, // 3 minutes in seconds
    BONUS_TIME: 15,
    PENALTY_TIME: 10,
    DRAW_PENALTY_TIME: 5
};

// Hacker Theme Colors
const COLORS = {
    PRIMARY_GREEN: '#00ff00',
    PRIMARY_BLUE: '#0080ff',
    PRIMARY_RED: '#ff0000',
    PRIMARY_YELLOW: '#ffff00',
    DARK_BACKGROUND: '#000000',
    DARK_GREEN: '#003300',
    WHITE: '#ffffff',
    BLACK: '#000000',
    GRAY: '#666666',
    GREEN: '#00ff00',
    RED: '#ff0000',
    ORANGE: '#ff0000',
    // Legacy support
    PRIMARY_GOLD: '#00ff00',
    PRIMARY_ORANGE: '#ff0000'
};

// Game Modes
const GAME_MODE = {
    AI_OPPONENT: 'aiOpponent',
    PLAYER_VS_PLAYER: 'playerVsPlayer'
};

// AI Difficulty Levels
const AI_DIFFICULTY = {
    EASY: 'easy',
    MEDIUM: 'medium',
    HARD: 'hard'
};

// Sound Effects
const SOUNDS = {
    MOVE: 'move',
    WIN: 'win',
    LOSE: 'lose',
    DRAW: 'draw',
    TAP: 'tap',
    ERROR: 'error'
};

// Winning Combinations (3x3 grid)
const WINNING_COMBINATIONS = [
    [0, 1, 2], // horizontal
    [3, 4, 5], // horizontal
    [6, 7, 8], // horizontal
    [0, 3, 6], // vertical
    [1, 4, 7], // vertical
    [2, 5, 8], // vertical
    [0, 4, 8], // diagonal
    [2, 4, 6]  // diagonal
];

// UI Constants
const UI = {
    CELL_CORNER_RADIUS: 8,
    CELL_BORDER_WIDTH: 2,
    CELL_SHADOW_RADIUS: 5,
    CELL_SHADOW_Y_OFFSET: 2,
    SPRING_RESPONSE: 0.3,
    SPRING_DAMPING_FRACTION: 0.7,
    CELL_ANIMATION_MASS: 0.8,
    CELL_ANIMATION_STIFFNESS: 300,
    CELL_ANIMATION_DAMPING: 20,
    CELL_ANIMATION_DURATION: 0.3
};

// Device Layout Constants
const DEVICE_LAYOUT = {
    IPHONE: {
        boardSpacing: 8,
        adaptiveSpacing: 16,
        scoreViewHeight: 80,
        scoreTimerSize: 24,
        scoreResultSize: 32,
        scoreIndicatorSize: 12,
        bottomSafeArea: 34,
        isIphone: true
    },
    IPAD: {
        boardSpacing: 12,
        adaptiveSpacing: 24,
        scoreViewHeight: 120,
        scoreTimerSize: 32,
        scoreResultSize: 48,
        scoreIndicatorSize: 16,
        bottomSafeArea: 0,
        isIphone: false
    }
};

// Animation Constants
const ANIMATIONS = {
    BOARD_SCALE: 1.015,
    CELL_SCALE: 1.2,
    BONUS_SCALE: 1.3,
    PENALTY_SCALE: 1.3,
    DURATION: {
        SHORT: 0.3,
        MEDIUM: 0.5,
        LONG: 0.8
    }
};

// Local Storage Keys
const STORAGE_KEYS = {
    PLAYER_STATS_X: 'playerStatsX',
    PLAYER_STATS_O: 'playerStatsO',
    GAME_SETTINGS: 'gameSettings',
    AI_DIFFICULTY: 'aiDifficulty',
    GAME_MODE: 'gameMode',
    SOUND_ENABLED: 'soundEnabled'
};

// Game States
const GAME_STATE = {
    MENU: 'menu',
    PLAYING: 'playing',
    PAUSED: 'paused',
    GAME_OVER: 'gameOver',
    SETTINGS: 'settings'
};

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        GAME_CONFIG,
        COLORS,
        GAME_MODE,
        AI_DIFFICULTY,
        SOUNDS,
        WINNING_COMBINATIONS,
        UI,
        DEVICE_LAYOUT,
        ANIMATIONS,
        STORAGE_KEYS,
        GAME_STATE
    };
}
