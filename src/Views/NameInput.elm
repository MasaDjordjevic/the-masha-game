module Views.NameInput exposing (..)

import Html exposing (Html, button, div, h1, h2, h3, input, span, text)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onClick, onInput)
import State exposing (Model, Msg(..))


nameInputView : Model -> Msg -> Html Msg
nameInputView model onClickMsg =
    div [ class "name-input-container" ]
        [ h1 [] [ text "ADD A NICKNAME" ]
        , input [ value model.nameInput, onInput UpdateNameInput ] []
        , button [ onClick onClickMsg ] [ text "Enter" ]
        ]