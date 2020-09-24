module Debugger.Update exposing (..)

import Dict
import Fixtures.Game exposing (emptyGame, getPlayerOnTurn, guessNextWords, lobbyGame, newlyStartedGame, restartWords)
import Fixtures.User exposing (defaultUser)
import Game.Words exposing (Words)
import State exposing (Model, Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.game of
        Just game ->
            case msg of
                DebugRestart ->
                    ( { model | game = Just (emptyGame game) }, Cmd.none )

                DebugLobby ->
                    ( { model | game = Just (lobbyGame game) }, Cmd.none )

                DebugStarted ->
                    ( { model | game = Just (newlyStartedGame game) }, Cmd.none )

                DebugRestartWords ->
                    ( { model | game = Just (restartWords game) }, Cmd.none )

                DebugSetPlayerOnTurn ->
                    let
                        playerOnTurn =
                            getPlayerOnTurn game
                    in
                    case playerOnTurn of
                        Just player ->
                            ( { model | localUser = Just player }, Cmd.none )

                        Maybe.Nothing ->
                            ( model, Cmd.none )

                DebugSetPlayerOwner ->
                    let
                        owner =
                            game.participants.players
                                |> Dict.toList
                                |> List.map Tuple.second
                                |> List.filter
                                    (\player -> player.name == game.creator)
                                |> List.head
                    in
                    case owner of
                        Just player ->
                            ( { model | localUser = Just player }, Cmd.none )

                        Maybe.Nothing ->
                            ( model, Cmd.none )

                DebugGuessNextWords ->
                    ( { model | game = Just (guessNextWords game) }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Nothing ->
            ( model, Cmd.none )
