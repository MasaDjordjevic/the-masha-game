port module Main exposing (..)

import Browser
import Debugger.Update
import Dict exposing (Dict)
import Game.Game exposing (..)
import Game.Gameplay
import Game.Participants
import Game.Status
import Game.Teams
import Game.Words exposing (Word)
import Json.Decode
import Json.Encode
import List
import Maybe
import State exposing (..)
import Time
import User exposing (..)
import Views.View exposing (view)


defaultTimer =
    60



--- PORTS ----


port registerLocalUser : String -> Cmd msg


port localUserRegistered : (User -> msg) -> Sub msg


port openGameAdded : (Json.Decode.Value -> msg) -> Sub msg


port gameNotFound : (() -> msg) -> Sub msg


port addGame : Json.Encode.Value -> Cmd msg


port requestToJoinGame : Game.Participants.GameRequest -> Cmd msg


port acceptRequest : Game.Participants.GameRequest -> Cmd msg


port gameChanged : (Json.Decode.Value -> msg) -> Sub msg


port changeGame : Json.Encode.Value -> Cmd msg


port findGame : Game.Game.FindGame -> Cmd msg


port addWord : Game.Words.AddWord -> Cmd msg


port deleteWord : Game.Words.DeleteWord -> Cmd msg



---- MODEL ----


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { localUser = Maybe.Nothing
      , nameInput = ""
      , game = Maybe.Nothing
      , wordInput = ""
      , isOwner = False -- TODO: this should not be separate from the game or should be Maybe
      , turnTimer = 60
      , environment = flags.environment
      , playMode = Maybe.Nothing
      , pinInput = ""
      , errors = []
      }
    , Cmd.none
    )



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetPlayMode mode ->
            ( { model | playMode = Just mode }, Cmd.none )

        LocalUserRegistered user ->
            ( { model | localUser = Just user }, Cmd.none )

        UpdateNameInput input ->
            ( { model | nameInput = String.toUpper input }, Cmd.none )

        UpdateWordInput input ->
            ( { model | wordInput = String.toUpper input }, Cmd.none )

        UpdatePinInput input ->
            ( { model | pinInput = String.toUpper input }, Cmd.none )

        RegisterLocalUser ->
            ( model, registerLocalUser model.nameInput )

        AddGame ->
            if String.isEmpty model.nameInput then
                ( model, Cmd.none )

            else
                let
                    tempUser =
                        User "" model.nameInput

                    newGame =
                        Game.Game.createGameModel tempUser
                in
                ( model
                , newGame
                    |> Game.Game.gameEncoder
                    |> addGame
                )

        OpenGameAdded value ->
            case Json.Decode.decodeValue gameDecoder value of
                Ok game ->
                    let
                        gameBelongsToUser =
                            case model.localUser of
                                Just usr ->
                                    game.creator == usr.name

                                Nothing ->
                                    False

                        playMode =
                            if gameBelongsToUser then
                                Just State.PlayingGame

                            else
                                Just State.JoiningGame
                    in
                    ( { model | game = Just game, isOwner = gameBelongsToUser, playMode = playMode }, Cmd.none )

                Err err ->
                    ( model, Cmd.none )

        EnterGame ->
            ( model, findGame (FindGame model.pinInput) )

        JoinGame ->
            case model.game of
                Just game ->
                    let
                        isPlayer =
                            game.participants.players
                                |> Dict.toList
                                |> List.map Tuple.second
                                |> List.map .name
                                |> List.member model.nameInput
                    in
                    if isPlayer then
                        ( { model | playMode = Just State.PlayingGame }, Cmd.none )

                    else
                        ( { model | playMode = Just State.PlayingGame }
                        , Game.Participants.GameRequest game.id (User "" model.nameInput)
                            |> requestToJoinGame
                        )

                Nothing ->
                    ( model, Cmd.none )

        GameChanged value ->
            case Json.Decode.decodeValue gameDecoder value of
                Ok game ->
                    case model.game of
                        Just ownGame ->
                            let
                                newTimer =
                                    case game.state.turnTimer of
                                        Ticking ->
                                            model.turnTimer

                                        Game.Game.NotTicking timerValue ->
                                            timerValue

                                        Game.Game.Restarted timerValue ->
                                            timerValue
                            in
                            if ownGame.id == game.id then
                                ( { model | game = Just game, turnTimer = newTimer }, Cmd.none )

                            else
                                ( model, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        AcceptUser user ->
            case ( model.game, model.isOwner ) of
                ( Just game, True ) ->
                    ( model
                    , Game.Participants.GameRequest game.id user
                        |> acceptRequest
                    )

                ( _, _ ) ->
                    ( model, Cmd.none )

        StartGame ->
            case ( model.game, model.isOwner ) of
                ( Just game, True ) ->
                    let
                        newGame =
                            Game.Gameplay.startGame game
                    in
                    ( model
                    , newGame
                        |> Game.Game.gameEncoder
                        |> changeGame
                    )

                ( _, _ ) ->
                    ( model, Cmd.none )

        State.AddWord ->
            case ( model.localUser, model.game, String.isEmpty model.wordInput ) of
                ( Just localUser, Just game, False ) ->
                    let
                        isPlayer =
                            Dict.member localUser.id game.participants.players

                        newWord =
                            Game.Words.wordWithKey 0 (Word model.wordInput localUser.name "")
                    in
                    if isPlayer then
                        ( { model | wordInput = "" }
                        , Game.Words.AddWord game.id newWord
                            |> addWord
                        )

                    else
                        ( model, Cmd.none )

                ( _, _, _ ) ->
                    ( model, Cmd.none )

        NextRound ->
            case ( model.game, model.isOwner ) of
                ( Just game, True ) ->
                    let
                        newGame =
                            Game.Gameplay.nextRound game
                    in
                    ( model
                    , newGame
                        |> Game.Game.gameEncoder
                        |> changeGame
                    )

                ( _, _ ) ->
                    ( model, Cmd.none )

        State.DeleteWord id ->
            case model.game of
                Just game ->
                    ( model, deleteWord (Game.Words.DeleteWord game.id id) )

                Nothing ->
                    ( model, Cmd.none )

        QuitGame ->
            case model.game of
                -- TODO: remove the player from the list of players or set to offline
                Just _ ->
                    ( { model | game = Maybe.Nothing }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        TimerTick _ ->
            case model.game of
                Just game ->
                    let
                        newTimerValue =
                            model.turnTimer - 1

                        cmd =
                            if newTimerValue < 0 && model.isOwner then
                                let
                                    newGame =
                                        Game.Gameplay.endOfExplaining game
                                in
                                newGame
                                    |> Game.Game.gameEncoder
                                    |> changeGame

                            else
                                Cmd.none
                    in
                    ( { model | turnTimer = newTimerValue }, cmd )

                Nothing ->
                    ( model, Cmd.none )

        SwitchTimer ->
            case ( model.game, model.localUser ) of
                ( Just game, Just localUser ) ->
                    let
                        canSwitchTimer =
                            Game.Gameplay.isLocalPlayersTurn game localUser

                        newGame =
                            if canSwitchTimer then
                                Game.Gameplay.switchTimer game model.turnTimer

                            else
                                game
                    in
                    if canSwitchTimer then
                        ( model
                        , newGame
                            |> Game.Game.gameEncoder
                            |> changeGame
                        )

                    else
                        ( model, Cmd.none )

                ( _, _ ) ->
                    ( model, Cmd.none )

        WordGuessed ->
            case model.game of
                Just game ->
                    let
                        newGameState =
                            Game.Gameplay.guessWord model.turnTimer game.state

                        newGame =
                            { game | state = newGameState }
                    in
                    ( model
                    , newGame
                        |> Game.Game.gameEncoder
                        |> changeGame
                    )

                Nothing ->
                    ( model, Cmd.none )

        GameNotFound ->
            ( { model | errors = [ "Game not found" ] }, Cmd.none )

        _ ->
            Debugger.Update.update msg model



---- SUBSCRIPTOINS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        timerSub =
            case model.game of
                Just game ->
                    case game.state.turnTimer of
                        Game.Game.Ticking ->
                            Time.every 1000 TimerTick

                        _ ->
                            Sub.none

                Nothing ->
                    Sub.none
    in
    Sub.batch
        [ localUserRegistered LocalUserRegistered
        , openGameAdded OpenGameAdded
        , gameNotFound (always GameNotFound)
        , gameChanged GameChanged
        , timerSub
        ]



---- VIEW ----
---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
