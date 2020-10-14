module Views.EndOfRound exposing (..)

import Game.Game exposing (Game)
import Html exposing (Html, button, div, h2, text)
import Html.Events exposing (onClick)
import State exposing (Model, Msg(..))


endOfRoundView : Game -> Bool -> Html Msg
endOfRoundView game isOwner =
    let
        buttonText =
            if game.state.round == 3 then
                "Finish game"

            else
                "Next round"
    in
    div []
        [ h2 [] [ text ("end of round " ++ String.fromInt game.state.round) ]
        , if isOwner then
            button [ onClick NextRound ] [ text "Next round" ]

          else
            text ""
        ]
