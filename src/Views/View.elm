module Views.View exposing (view)

import Debugger.Debugger exposing (debugger)
import Dict exposing (Dict)
import Game.Game exposing (Game)
import Game.Gameplay
import Game.Status
import Game.Teams
import Game.Words
import Html exposing (Html, button, div, h1, h2, h3, input, label, p, span, table, td, text, th, tr)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import State exposing (..)
import User exposing (User)
import Views.AddingWords exposing (addingWordsView)
import Views.EndOfRound exposing (endOfRoundView)
import Views.FinishedGame exposing (finishedGameView)
import Views.Lobby exposing (lobbyView)
import Views.NameInput exposing (nameInputView)
import Views.Playing.Playing exposing (playingView)
import Views.Start exposing (startView)


header : Html Msg
header =
    div [ class "header" ]
        [ span [ class "confetti-large", class "mirrored" ] [ text "🎉" ]
        , span [ class "title" ] [ text "THE MASHA GAME" ]
        , span [ class "confetti-large" ] [ text "🎉" ]
        ]


view : Model -> Html Msg
view model =
    let
        currView =
            case model.playMode of
                Just PlayingGame ->
                    case model.game of
                        Just game ->
                            let
                                isRoundEnd =
                                    Game.Gameplay.isRoundEnd game
                            in
                            case game.status of
                                Game.Status.Open ->
                                    lobbyView model

                                Game.Status.Running ->
                                    if isRoundEnd && game.round > 0 then
                                        endOfRoundView game model.isOwner

                                    else
                                        case game.round of
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
                header

              else
                text ""
            , currView
            ]
        , debugger model
        ]
