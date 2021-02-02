module Views.Start exposing (..)

import Html exposing (Html, button, div, h1, h2, h3, input, span, text)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onClick, onInput)
import State exposing (Model, Msg(..))
import State exposing (InitialGameModel)
import State exposing (Errors)


gameNotFoundView : Errors -> Html Msg
gameNotFoundView errors =
    case List.head errors of
        Just error ->
            h3 [ class "error" ] [ text error ]

        Nothing ->
            text ""


startView : InitialGameModel -> Errors -> Html Msg
startView model erros =
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
            [ class "create-btn", onClick (SetCreatingGameMode) ]
            [ text "Create new game" ]
        , span [ class "or" ] [ text "OR" ]
        , div [ class "join" ]
            [ h2 [] [ text "ENTER WITH GAME PIN" ]
            , input [ type_ "text", value model.pinInput, onInput UpdatePinInput ] []
            , gameNotFoundView erros
            , button [ onClick EnterGame ] [ text "Enter" ]
            ]
        ]
