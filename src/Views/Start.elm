module Views.Start exposing (..)

import Html exposing (Html, button, div, h1, h2, h3, input, span, text)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onClick, onInput)
import State exposing (Model, Msg(..), PlayMode(..))


startView : Model -> Html Msg
startView model =
    div [ class "container" ]
        [ div []
            [ span [ class "confetti", class "mirrored" ] [ text "🎉" ]
            , span [ class "pre-title" ] [ text " Time to party, time for " ]
            , span [ class "confetti" ] [ text "🎉" ]
            ]
        , div []
            [ h1 [ class "title-large" ] [ text "THE MASHA GAME" ]
            ]
        , button
            [ class "create-btn", onClick (SetPlayMode State.CreatingGame) ]
            [ text "Create new game" ]
        , span [ class "or" ] [ text "OR" ]
        , div [ class "join" ]
            [ h2 [] [ text "ENTER WITH GAME PIN" ]
            , input [ type_ "text", value model.pinInput, onInput UpdatePinInput ] []
            , button [ onClick EnterGame ] [ text "Enter" ]
            ]
        ]
