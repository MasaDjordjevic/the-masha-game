port module Main exposing (..)

import Browser
import Game exposing (..)
import Json.Decode
import Json.Encode
import List
import Maybe
import State exposing (..)
import User exposing (..)
import View exposing (view)



--- PORTS ----


port registerLocalUser : String -> Cmd msg


port localUserRegistered : (User -> msg) -> Sub msg


port openGameAdded : (Json.Decode.Value -> msg) -> Sub msg


port addGame : Json.Encode.Value -> Cmd msg



---- MODEL ----


init : ( Model, Cmd Msg )
init =
    ( { localUser = Maybe.Nothing
      , nameInput = ""
      , openGames = []
      }
    , Cmd.none
    )



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LocalUserRegistered user ->
            ( { model | localUser = Just user }, Cmd.none )

        UpdateNameInput input ->
            ( { model | nameInput = input }, Cmd.none )

        RegisterLocalUser ->
            ( model, registerLocalUser model.nameInput )

        OpenGameAdded value ->
            case Json.Decode.decodeValue gameDecoder value of
                Ok game ->
                    ( { model | openGames = List.append model.openGames [ game ] }, Cmd.none )

                Err err ->
                    let
                        _ =
                            Debug.log "OpenGameAdded Error: " err
                    in
                    ( model, Cmd.none )

        AddGame ->
            case model.localUser of
                Just user ->
                    ( model
                    , user.name
                        |> Game.createGameModel
                        |> Game.gameEncoder
                        |> addGame
                    )

                Nothing ->
                    ( model, Cmd.none )



---- SUBSCRIPTOINS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ localUserRegistered LocalUserRegistered
        , openGameAdded OpenGameAdded
        ]



---- VIEW ----
---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
