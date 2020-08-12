module State exposing (..)

import Game exposing (Game)
import Json.Decode
import User exposing (User)


type alias Model =
    { localUser : Maybe User
    , nameInput : String
    , openGames : List Game
    }


type Msg
    = LocalUserRegistered User
    | UpdateNameInput String
    | RegisterLocalUser
    | OpenGameAdded Json.Decode.Value
    | AddGame
