module State exposing (..)

import Game.Game exposing (Game)
import Json.Decode
import Time
import User exposing (User)
import Http


type alias Flags =
    { environment : String
    }

type alias PlayingGameModel = { localUser : User, game : Game, isOwner : Bool,  wordInput : String, turnTimer : Int, isRoundEnd : Bool }
type alias InitialGameModel = { pinInput : String }


type GameModel 
    = Initial InitialGameModel
    | CreatingGame { nameInput : String } 
    | JoiningGame { game: Game, nameInput : String } 
    | Playing PlayingGameModel

type alias Errors = List String

type alias Model = 
    { currentGame: GameModel
    , environment : String
    , apiUrl: String
    , errors : Errors
    , isHelpDialogOpen : Bool
    , isDonateDialogOpen: Bool
    }


type Msg
    = SetCreatingGameMode 
    | UpdateNameInput String
    | GameNotFound
    | AddGame
    | JoinGame
    | EnterGame
    | GameChanged Json.Decode.Value
    | AcceptUser User
    | StartGame
    | UpdateWordInput String
    | UpdatePinInput String
    | AddWord
    | NextRound
    | InitiateNextRound
    | DeleteWord String
    | QuitGame
    | TimerTick Time.Posix
    | SwitchTimer
    | WordGuessed
    | ToggleHelpDialog
    | ToggleDonateDialog
    | DebugRestart
    | DebugLobby
    | DebugStarted
    | DebugRestartWords
    | DebugSetPlayerOnTurn
    | DebugSetPlayerOwner
    | DebugSetNextPlayer
    | DebugGuessNextWords
    | GameFound (Result Http.Error Game)
    | GameAdded (Result Http.Error (Game, User))
    | JoinedGame (Result Http.Error (String, User))
    | NoOpResult (Result Http.Error String)
