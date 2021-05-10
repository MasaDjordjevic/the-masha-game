module Views.Donate exposing (donateView)

import Html exposing (Html, b, button, div, h2, h4, span, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import State exposing (GameModel(..), Model, Msg(..))
import Views.Header exposing (headerView)
import Html exposing (br)
import Html exposing (p)
import Html exposing (a)
import Html.Attributes exposing (href)





donateContent :  Html Msg
donateContent  =
    
    div [ class "donate-dialog",  onClick ToggleDonateDialog ]
        [ span [] [ text "Are you enjoying the game and would like to support? 🥰" ]
        , span [] [ text "You can do so here" ]
        , a [ href "https://paypal.me/masadordevic", class "donate-button"] [text "♡ Support"]
        , button [class "close-button"] [text "𝗫"]
        ]

        


donateView : Model -> Html Msg
donateView model =
    let
        isSmall =
            case model.currentGame of
                Playing _ ->
                    True

                _ ->
                    False

    in
        div [ class "donate-dialog-container"] [
            if model.isDonateDialogOpen 
                then
                    donateContent
                else
                    div [ classList [ ( "donate-dialog-button", True ), ( "small", isSmall ) ], onClick ToggleDonateDialog ]
                        [ span [] [ text "♡" ]
                     
            ]
        ]

       
