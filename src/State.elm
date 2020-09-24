module State exposing (..)

import Game.Game exposing (Game)
import Json.Decode
import Time
import User exposing (User)


type alias Flags =
    { environment : String
    }


type alias Model =
    { localUser : Maybe User
    , nameInput : String
    , wordInput : String
    , openGames : List Game
    , game : Maybe Game
    , isOwner : Bool
    , turnTimer : Int
    , environment : String
    }


type Msg
    = LocalUserRegistered User
    | UpdateNameInput String
    | RegisterLocalUser
    | OpenGameAdded Json.Decode.Value
    | AddGame
    | JoinGame Game
    | GameChanged Json.Decode.Value
    | AcceptUser User
    | StartGame
    | UpdateWordInput String
    | AddWord
    | NextRound
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
