module State exposing (..)

import Game.Game exposing (Game)
import Json.Decode
import Time
import User exposing (User)
import Http


type alias Flags =
    { environment : String
    }


type PlayMode
    = CreatingGame
    | JoiningGame
    | PlayingGame


type ViewState
    = Initial
    | NameInput


type alias Model =
    { localUser : Maybe User
    , nameInput : String
    , wordInput : String
    , pinInput : String
    , game : Maybe Game
    , isOwner : Bool
    , turnTimer : Int
    , environment : String
    , apiUrl: String
    , playMode : Maybe PlayMode
    , errors : List String
    , isRoundEnd : Bool
    , isHelpDialogOpen : Bool
    }


type Msg
    = LocalUserRegistered User
    | SetPlayMode PlayMode
    | UpdateNameInput String
    | RegisterLocalUser
    | OpenGameAdded Json.Decode.Value
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
    | DebugRestart
    | DebugLobby
    | DebugStarted
    | DebugRestartWords
    | DebugSetPlayerOnTurn
    | DebugSetPlayerOwner
    | DebugGuessNextWords
    | GameFound (Result Http.Error Game)
    | GameAdded (Result Http.Error (Game, User))
