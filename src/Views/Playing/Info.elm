module Views.Playing.Info exposing (..)

import Game.Game exposing (Game, TurnTimer)
import Game.Gameplay exposing (isLocalPlayersTurn)
import Html exposing (Html, button, div, h1, h3, span, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import State exposing (Model, Msg(..))
import User exposing (User)
import Views.Playing.CurrentWord exposing (currentWordView)
import Views.Playing.Round exposing (roundView)


wordsLeft : Game -> Bool -> Html Msg
wordsLeft game isExplaining =
    let
        wordsLeftCount =
            case game.state.words.current of
                Just _ ->
                    1 + List.length game.state.words.next

                Nothing ->
                    List.length game.state.words.next
    in
    div [ classList [ ( "info-container", True ), ( "small", isExplaining ) ] ]
        [ h1 [] [ text (String.fromInt wordsLeftCount) ]
        , span []
            [ text "words left"
            ]
        ]


timeLeft : Int -> Html Msg
timeLeft localTimer =
    div [ class "info-container" ]
        [ h1 [] [ text (String.fromInt localTimer) ]
        , span []
            [ text "seconds"
            ]
        ]


previousWord : Game -> User -> Html Msg
previousWord game localUser =
    let
        prevWord =
            List.head game.state.words.guessed

        isOnTurn =
            isLocalPlayersTurn game localUser
    in
    case ( prevWord, isOnTurn ) of
        ( Just word, False ) ->
            div [ class "info-container", class "previous-word" ]
                [ h1 [] [ text word.word ]
                , span [] [ text "previous" ]
                ]

        ( _, _ ) ->
            text ""


getTimerString : TurnTimer -> String
getTimerString turnTimer =
    case turnTimer of
        Game.Game.Ticking ->
            "Pause"

        Game.Game.NotTicking _ ->
            "Continue"

        Game.Game.Restarted _ ->
            ""


timerButton : Game -> Bool -> Html Msg
timerButton game isExplaining =
    let
        timerString =
            getTimerString game.state.turnTimer

        shouldShowButton =
            (String.isEmpty >> not) timerString
    in
    if isExplaining then
        div [ class "timer-button-container" ]
            [ if shouldShowButton then
                button [ class "timer-button", onClick SwitchTimer ]
                    [ span [ class "material-icons" ] [ text "access_time" ]
                    , span [] [ text timerString ]
                    ]

              else
                text ""
            ]

    else
        text ""


infoView : Game -> User -> Int -> Html Msg
infoView game localUser localTimer =
    let
        isExplaining =
            Game.Gameplay.isExplaining game localUser

        canSwitchTimer =
            case game.state.turnTimer of
                Game.Game.Restarted _ ->
                    Basics.False

                _ ->
                    True
    in
    div
        [ classList [ ( "turn-stats", True ), ( "section", True ), ( "on-turn", isExplaining ) ] ]
        [ wordsLeft game isExplaining
        , timeLeft localTimer
        , previousWord game localUser
        , timerButton game isExplaining
        ]
