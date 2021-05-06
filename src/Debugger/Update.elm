module Debugger.Update exposing (..)

import Dict
import Fixtures.Game exposing (emptyGame, getPlayerOnTurn, guessNextWords, lobbyGame, newlyStartedGame, restartWords)
import Fixtures.User exposing (defaultUser)
import Game.Words exposing (Words)
import State exposing (Model, Msg(..))
import State exposing (GameModel(..))
import State exposing (PlayingGameModel)
import Game.Game exposing (Game)


upadateGame: PlayingGameModel -> Game -> GameModel
upadateGame gameModel game = 
    Playing ({gameModel | game = game})

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.currentGame of
        Playing gameModel ->
            case msg of
                DebugRestart ->
                    ( { model | currentGame = upadateGame gameModel (emptyGame gameModel.game) }, Cmd.none )

                DebugLobby ->
                    ( { model | currentGame = upadateGame gameModel (lobbyGame gameModel.game) }, Cmd.none )

                DebugStarted ->
                    ( { model | currentGame = upadateGame gameModel (newlyStartedGame gameModel.game) }, Cmd.none )

                DebugRestartWords ->
                    ( { model | currentGame = upadateGame gameModel  (restartWords gameModel.game) }, Cmd.none )

                DebugSetPlayerOnTurn ->
                    let
                        playerOnTurn =
                            getPlayerOnTurn gameModel.game
                    in
                    case playerOnTurn of
                        Just player ->
                            ( { model | currentGame = Playing ({gameModel | localUser = player })  }, Cmd.none )

                        Maybe.Nothing ->
                            ( model, Cmd.none )

                DebugSetPlayerOwner ->
                    let
                        owner =
                            gameModel.game.participants.players
                                |> Dict.toList
                                |> List.map Tuple.second
                                |> List.filter
                                    (\player -> player.name == gameModel.game.creator)
                                |> List.head
                    in
                    case owner of
                        Just player ->
                            ( { model | currentGame = Playing ({gameModel | localUser = player, isOwner = True }) }, Cmd.none )

                        Maybe.Nothing ->
                            ( model, Cmd.none )

                DebugGuessNextWords ->
                    ( { model | currentGame = upadateGame gameModel (guessNextWords gameModel.game) }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )
