module Views.BetweenRounds exposing (..)

import Game.Game exposing (Game)
import Game.Gameplay exposing (nextRound)
import Html exposing (Html, div, h3, text)
import Html.Attributes exposing (class)
import State exposing (Msg(..))
import Views.Playing.Round exposing (getRoundText)


betweenRoundsView : Game -> Html Msg
betweenRoundsView game =
    let
        nextRound =
            game.state.round + 1
    in
    case nextRound of
        1 ->
            div [ class "between-rounds-container", class "section" ]
                [ h3 [ class "show-first" ] [ text "Hope you are soooo ready..." ]
                , h3 [ class "show-second" ] [ text "...Because it is time to EXPLAIN..." ]
                , h3 [ class "show-third" ] [ text "...as many words as you can..." ]
                ]

        4 ->
            div [ class "between-rounds-container", class "section" ]
                [ h3 [ class "show-first" ] [ text "Hope you had lots of fun..." ]
                , h3 [ class "show-second" ] [ text "...Because the game has ended..." ]
                , h3 [ class "show-third large-text" ] [ text "...aaaand..." ]
                ]

        -- 2 and 3
        _ ->
            div [ class "between-rounds-container", class "section" ]
                [ h3 [ class "show-first" ] [ text "Hope you remember the words..." ]
                , h3 [ class "show-second" ] [ text "...Because now it’s time for..." ]
                , h3 [ class "show-third large-text" ] [ text (getRoundText nextRound) ]
                ]
