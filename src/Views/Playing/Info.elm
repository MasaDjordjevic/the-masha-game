module Views.Playing.Info exposing (..)

import Game.Game exposing (Game, TurnTimer)
import Game.Gameplay exposing (canSwitchTimer, isLocalPlayersTurn)
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
        [ h3 []
            [ text "Words left "
            ]
        , h1 [] [ text (String.fromInt wordsLeftCount) ]
        ]


timeLeft : Int -> Html Msg
timeLeft localTimer =
    div [ class "info-container" ]
        [ h3 []
            [ text "Time left "
            ]
        , h1 [] [ text (String.fromInt localTimer) ]
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
            div [ class "info-container" ]
                [ h3 [] [ text "Previous word " ]
                , div [ class "previous-word" ]
                    [ h1 [] [ text word.word ]
                    ]
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
            getTimerString game.turnTimer

        shouldShowButton =
            (String.isEmpty >> not) timerString
    in
    if isExplaining then
        div [ class "timer-button-container" ]
            [ if shouldShowButton then
                button [ class "timer-button", onClick SwitchTimer ] [ text timerString ]

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
            case game.turnTimer of
                Game.Game.Restarted _ ->
                    Basics.False

                _ ->
                    True
    in
    div
        [ classList [ ( "turn-stats", True ), ( "section", True ), ( "on-turn", isExplaining ) ] ]
        [ wordsLeft game isExplaining
        , previousWord game localUser
        , timeLeft localTimer
        , timerButton game isExplaining
        ]
