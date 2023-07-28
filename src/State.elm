module State exposing (..)

import Browser
import Browser.Navigation
import Game.Game exposing (Game)
import Http
import Json.Decode
import Route exposing (Route)
import Time
import Url
import User exposing (User)


type alias Flags =
    { environment : String
    }


type alias PlayingGameModel =
    { localUser : User, game : Game, isOwner : Bool, wordInput : String, turnTimer : Int, isRoundEnd : Bool }


type alias InitialGameModel =
    { pinInput : String }


type GameModel
    = Initial InitialGameModel
    | CreatingGame { nameInput : String }
    | JoiningGame { game : Maybe Game, nameInput : String }
    | Playing PlayingGameModel


type alias Errors =
    List String


type alias Model =
    { currentGame : GameModel
    , environment : String
    , apiUrl : String
    , errors : Errors
    , isHelpDialogOpen : Bool
    , isDonateDialogOpen : Bool
    , url : Url.Url
    , route : Route
    , navKey : Browser.Navigation.Key
    }


type Msg
    = UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest
    | SetCreatingGameMode
    | UpdateNameInput String
    | GameNotFound
    | AddGame
    | JoinGame
    | EnterGame
    | GameChanged Json.Decode.Value
    | AcceptUser User
    | StartGame
    | CopyInviteLink
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
    | GameAdded (Result Http.Error ( Game, User ))
    | JoinedGame (Result Http.Error ( String, User ))
    | NoOpResult (Result Http.Error String)
