module State exposing (..)

import Game.Game exposing (Game)
import Json.Decode
import Time
import User exposing (User)


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
    , playMode : Maybe PlayMode
    , errors : List String
    , isRoundEnd : Bool
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
    | DebugRestart
    | DebugLobby
    | DebugStarted
    | DebugRestartWords
    | DebugSetPlayerOnTurn
    | DebugSetPlayerOwner
    | DebugGuessNextWords
