module Debugger.Debugger exposing (..)

import Html exposing (Html, button, div, p, text)
import Html.Events exposing (onClick)
import State exposing (Model, Msg(..))


debugger : Model -> Html Msg
debugger model =
    case model.environment of
        "development" ->
            div []
                [ p [] [ text "DEBUGGER" ]
                , button [ onClick DebugRestart ] [ text "Restart" ]
                , button [ onClick DebugLobby ] [ text "Lobby" ]
                , button [ onClick DebugStarted ] [ text "Newly started" ]
                , button [ onClick DebugRestartWords ] [ text "Restart words" ]
                , button [ onClick DebugSetNextPlayer ] [ text "Set next player" ]
                , button [ onClick DebugSetPlayerOnTurn ] [ text "Set player on turn" ]
                , button [ onClick DebugSetPlayerOwner ] [ text "Set player owner" ]
                , button [ onClick DebugGuessNextWords ] [ text "Guess next words" ]
                ]

        _ ->
            text ""
