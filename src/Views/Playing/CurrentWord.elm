module Views.Playing.CurrentWord exposing (..)

import Game.Game exposing (Game)
import Game.Gameplay exposing (isExplaining)
import Game.Words exposing (Word)
import Html exposing (Html, button, div, h1, h3, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import State exposing (Model, Msg(..))
import User exposing (User)


start : Html Msg
start =
    div [ class "current-word-container", class "section" ]
        [ h3 [ class "show-first" ] [ text "It’s your turn" ]
        , h3 [ class "show-second" ] [ text "You’ll see the word here" ]
        , button [ class "show-third", onClick SwitchTimer ] [ text "Start" ]
        ]


currentWord : Word -> Html Msg
currentWord word =
    div [ class "section" ]
        [ div [ class "current-word-container", class "has-word" ]
            [ h1 [ class "current-word", onClick WordGuessed ] [ text word.word ]
            ]
        , button [ class "next-word", onClick WordGuessed ] [ text "Done! Next word" ]
        ]


currentWordView : Game -> User -> Html Msg
currentWordView game localUser =
    if isExplaining game localUser then
        case game.state.words.current of
            Just word ->
                currentWord word

            Nothing ->
                start

    else
        text ""
