module Views.Playing.Round exposing (..)

import Html exposing (Html, div, h1, h3, text)
import Html.Attributes exposing (class)
import State exposing (Model, Msg)


getRoundText : Int -> String
getRoundText round =
    case round of
        1 ->
            "describe the word"

        2 ->
            "charades"

        3 ->
            "one word guess"

        4 ->
            "The game has ended 🎉"

        _ ->
            ""


roundView : Int -> Html Msg
roundView round =
    div [ class "info-container", class "section" ]
        [ h3 []
            [ text ("Round " ++ String.fromInt round)
            ]
        , h1 [] [ text (getRoundText round) ]
        ]
