module Views.Help exposing (helpView)

import Html exposing (Html, b, button, div, h2, span, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import State exposing (Model, Msg(..))
import Views.Header exposing (headerView)


type HelpContext
    = Initial
    | Round Int


helpContent : HelpContext -> Html Msg
helpContent context =
    case context of
        Initial ->
            div []
                [ h2 [] [ text "How to play" ]
                , span [] [ text "This game is all about words. But not just any words. ", b [] [ text "Nouns" ], text "." ]
                , span []
                    [ text "It is played in teams of 2 and has 3 phases: "
                    , b [] [ text "Describe" ]
                    , span [] [ text "," ]
                    , b [] [ text "Charade" ]
                    , span [] [ text " and " ]
                    , b [] [ text "One word" ]
                    ]
                , span [] [ text "The game starts with writing down words. Then we get devided in teams (pairs). Each team gets 60 seconds where one player tries to explain as many words as possible to the other player. Be attentive and try to remember the words, because once we explain them all, we play the next round with the same words. " ]
                ]

        _ ->
            text "If something went wrong try refreshing the page and re-joining the game by entering the same game code and using the same username."


helpView : Model -> Html Msg
helpView model =
    let
        context =
            case model.game of
                Just game ->
                    Round game.state.round

                Nothing ->
                    Initial

        isSmall =
            case context of
                Initial ->
                    False

                _ ->
                    True
    in
    div []
        [ if model.isHelpDialogOpen then
            div [ class "help-dialog", onClick ToggleHelpDialog ]
                [ headerView
                , div [ class "help-dialog-content" ] [ helpContent context ]
                ]

          else
            div [ classList [ ( "help-dialog-button", True ), ( "small", isSmall ) ], onClick ToggleHelpDialog ]
                [ span [] [ text "?" ]
                ]
        ]
