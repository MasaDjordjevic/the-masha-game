module Views.View exposing (view)

import Debugger.Debugger exposing (debugger)
import Dict exposing (Dict)
import Game.Game exposing (Game)
import Game.Gameplay
import Game.Status
import Game.Teams
import Game.Words
import Html exposing (Html, button, div, h1, h2, h3, header, input, label, p, span, table, td, text, th, tr)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import State exposing (..)
import User exposing (User)
import Views.AddingWords exposing (addingWordsView)
import Views.EndOfRound exposing (endOfRoundView)
import Views.FinishedGame exposing (finishedGameView)
import Views.Header exposing (headerView)
import Views.Help exposing (helpView)
import Views.Lobby exposing (lobbyView)
import Views.NameInput exposing (nameInputView)
import Views.Playing.Playing exposing (playingView)
import Views.Start exposing (startView)


view : Model -> Html Msg
view model =
    let
        currView =
            case model.playMode of
                Just PlayingGame ->
                    case model.game of
                        Just game ->
                            case game.status of
                                Game.Status.Open ->
                                    lobbyView model

                                Game.Status.Running ->
                                    if model.isRoundEnd then
                                        endOfRoundView game

                                    else
                                        case game.state.round of
                                            0 ->
                                                addingWordsView model

                                            _ ->
                                                playingView model

                                Game.Status.Finished ->
                                    finishedGameView game

                        Nothing ->
                            text "you are in weird state"

                Just CreatingGame ->
                    nameInputView model AddGame

                Just JoiningGame ->
                    nameInputView model JoinGame

                Nothing ->
                    startView model

        showHeader =
            case model.playMode of
                Just _ ->
                    Basics.True

                Nothing ->
                    Basics.False
    in
    div []
        [ div [ class "page-container" ]
            [ if showHeader then
                headerView

              else
                text ""
            , currView
            , helpView model
            ]
        , debugger model
        ]
