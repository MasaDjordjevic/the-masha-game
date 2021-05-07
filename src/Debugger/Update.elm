module Debugger.Update exposing (..)

import Dict
import Fixtures.Game exposing (emptyGame, getPlayerOnTurn, guessNextWords, lobbyGame, newlyStartedGame, restartWords)
import Fixtures.User exposing (defaultUser)
import Game.Words exposing (Words)
import State exposing (Model, Msg(..))
import State exposing (GameModel(..))
import State exposing (PlayingGameModel)
import Game.Game exposing (Game)
import Player exposing (Player)
import User exposing (User)
import Game.Teams exposing (advanceCurrentTeam)
import Maybe exposing (withDefault)


upadateGame: PlayingGameModel -> Game -> GameModel
upadateGame gameModel game = 
    let
        localUser = gameModel.localUser
        isPlayer = Dict.member localUser.id game.participants.players

        newLocalUser = 
            if isPlayer 
                then 
                    localUser
                else
                    Dict.values game.participants.players
                     |> List.head
                     |> withDefault localUser
    in
    Playing ({gameModel | game = game, localUser = newLocalUser})

getOwner: PlayingGameModel -> Maybe User
getOwner gameModel= 
     gameModel.game.participants.players
                                |> Dict.toList
                                |> List.map Tuple.second
                                |> List.filter
                                    (\pl -> pl.name == gameModel.game.creator)
                                |> List.head
isOwner: PlayingGameModel -> Player -> Bool
isOwner gameModel player= 
    let
        owner = getOwner gameModel
    in
        case owner of
            Just own ->
                own.id == player.userId
            Nothing -> 
                False

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
                
                DebugSetNextPlayer ->
                    let
                        newTeams = advanceCurrentTeam gameModel.game.state.teams 
                        oldState = gameModel.game.state
                        newState = { oldState | teams = newTeams}
                        oldGame = gameModel.game
                        newGame = {oldGame | state = newState }
                    in
                        ({model | currentGame = upadateGame gameModel newGame}, Cmd.none)

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
                    case getOwner gameModel of
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
