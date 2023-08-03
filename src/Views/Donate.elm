module Views.Donate exposing (donateView)

import Html exposing (Html, a, button, div, span, text)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import State exposing (GameModel(..), Model, Msg(..))


donateContent : Html Msg
donateContent =
    div [ class "donate-dialog", onClick ToggleDonateDialog ]
        [ span [] [ text "Are you enjoying the game and would like to support? 🥰" ]
        , span [] [ text "You can do so here ->" ]
        , a [ href "https://paypal.me/masadordevic", class "donate-button" ] [ text "♡ Support" ]
        , button [ class "close-button" ] [ text "𝗫" ]
        ]


donateView : Model -> Html Msg
donateView model =
    div [ class "donate-dialog-container" ]
        [ if model.isDonateDialogOpen then
            donateContent

          else
            div [ class "donate-dialog-button", onClick ToggleDonateDialog ]
                [ span [] [ text "♡" ]
                ]
        ]
