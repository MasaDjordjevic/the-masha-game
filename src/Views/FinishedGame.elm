module Views.FinishedGame exposing (..)

import Game.Game exposing (Game)
import Game.Words exposing (Word)
import Html exposing (Html, div, h2, h3, h4, span, text)
import Html.Attributes exposing (class)
import State exposing (Msg)
import Views.Playing.Teams exposing (teamsView)


wordView : Word -> Html Msg
wordView word =
    div []
        [ h2 []
            [ text word.word ]
        , h4
            []
            [ text word.player ]
        ]


finishedGameView : Game -> Html Msg
finishedGameView game =
    div []
        [ h2 []
            [ text "The game is finished" ]
        , teamsView game
        , div
            [ class "words-overview-wrapper " ]
            [ h3 [] [ text "Words overview" ]
            , game.state.words.next
                |> List.map wordView
                |> div [ class "words-overview-container" ]
            ]
        ]
