module Views.Header exposing (headerView)

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class)
import State exposing (Msg)


headerView : Html Msg
headerView =
    div [ class "header" ]
        [ span [ class "confetti-large", class "mirrored" ] [ text "🎉" ]
        , span [ class "title" ] [ text "THE MASHA GAME" ]
        , span [ class "confetti-large" ] [ text "🎉" ]
        ]
