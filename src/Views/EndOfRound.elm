module Views.EndOfRound exposing (..)

import Game.Game exposing (Game)
import Html exposing (Html, button, div, h2, h3, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import State exposing (Model, Msg(..))
import Views.Playing.Round exposing (getRoundText)


endOfRoundView : Game -> Html Msg
endOfRoundView game =
    div [ class "end-of-round-container", class "section" ]
        [ h3 [ class "show-first" ] [ text "Hope you remember the words..." ]
        , h3 [ class "show-second" ] [ text "...Because now it’s time for..." ]
        , h3 [ class "show-third" ] [ text (getRoundText (game.state.round + 1)) ]
        ]
