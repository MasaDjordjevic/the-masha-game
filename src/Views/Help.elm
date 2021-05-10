module Views.Help exposing (helpView)

import Html exposing (Html, b, button, div, h2, h4, span, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import State exposing (GameModel(..), Model, Msg(..))
import Views.Header exposing (headerView)
import Html exposing (br)
import Html exposing (p)


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
                , span [] [ text "The game starts with writing down words. Then we get divided in teams (pairs). Each team gets 60 seconds where one player tries to explain as many words as possible to the other player. Be attentive and try to remember the words, because once we explain them all, we play the next round with the same words. " ]
                , span [] [ text "Gather around or join with your friends in an online meeting and get started! 🥳"]
                ]

        Round 0 ->
            div []
                [ h2 [] [ text "Adding words" ]
                , span [] [ text "Now all players add words that are going to be described later." ]
                , span []
                    [ text "There are only two rules: "
                    , text "words have to be "
                    , b [] [ text "nouns" ]
                    , text " , and they "
                    , b [] [ text "can't" ]
                    , text " be "
                    , b [] [ text "proper nouns" ]
                    ]
                , span []
                    [ text "Here are some examples: "
                    ]
                , span [class "examples"]
                    [ span [ class "correct" ] [ text "car" ]
                    , span [ ] [ span [ class "incorrect"] [text "blue car"], br [] [] , text "(should be one generic term)" ]
                    , span [ class "correct" ] [ text "government" ]
                    , span [  ] [ span [class "incorrect"] [text "Harry Potter"], br [] [] , text " (should not be a proper noun)" ]
                    , span [ class "correct" ] [ text "sunbed" ] 
                    , span [ ] [span [class "incorrect"] [text "walk"], br [] [] , text " (should be a noun)" ]
                    ]
                , h4 [] [ text "How many words should we add?" ]
                , span [] [ text "It's up to you to agree on! It depends on the number of players and how long you would like to play. We recommend having 35-50 words in total." ]
                ]

        Round 1 ->
            div []
                [
                    h2 [] [ text "Describing"]
                    , span [] [ text "Once it's your turn to describe words you'll see the start button and words will show up."]
                    , span [] [ text "There's only one rule: you can't say ", b [] [text "the root of the word"], text "."]
                    , span [] [ text "For example: if a word is \"sunbed\"", text " avoid explaining it as \"a  ",b[] [text "bed"], text " you lay on while being on the ", b[] [text "sun"], text ", or while ", b[] [text "sun"], text  "tanning\". All the ", b[] [text "bold"], text " words in the previous example are violations."]
                    , br [] []
                    , span [] [ 
                        text "Some more examples would be:"
                        , span [class "examples"]
                            [ span [] [ text "\"row row row your... \""]
                            , span [] [ text "🤔 boat!"]
                            , span [] [ text "\"a car has 4... \""]
                            , span [] [ text "🤔 wheels!... or wheel*"]
                            , span [] [ text "\"sour fruit... \""]
                            , span [] [ text "lemon! ⛔️ lime?! ✅"]
                        ]
                        ]

                ]

        Round 2 ->
            div [] 
                [
                    h2 [] [ text "Charades"]
                    , span [] [ text "We're playing standard charades with the same words that we had in the prevous round."]
                    , span [] [  text "There's only one rule: you can't make sounds (for example humming or \"bzzz\" sounds)"]
                    , span [] [ text "🙊"]
                ]

        Round 3 ->
            div [] 
                [
                    h2 [] [ text "One word"]
                    , span [] [ text "In this round we're explaining words with only ",  b [] [text "one word"], text "."]
                    , span [] [ text "We played two rounds with the same words already so we can explain words with only one word now! Here are some examples: " ]
                      , span [class "examples"]
                            [ span [] [ text "\"rowing... \""]
                            , span [] [ text "🤔 boat!"]
                            , span [] [ text "\"steering... \""]
                            , span [] [ text "🤔 wheel"]
                            , span [] [ text "\"sour... \""]
                            , span [] [ text "lime"]
                        ]
                ]

        _ ->
            text ""


helpView : Model -> Html Msg
helpView model =
    let
        context =
            case model.currentGame of
                Playing gameModel ->
                    Round gameModel.game.state.round

                _ ->
                    Initial

        isSmall =
            case context of
                Initial ->
                    False

                _ ->
                    True
    in
    div [ class "help-dialog-container"]
        [ if model.isHelpDialogOpen then
            div [ class "help-dialog", onClick ToggleHelpDialog ]
                [ headerView
                , div [ class "help-dialog-content" ] 
                    [ helpContent context
                    , span [class "bottom"][ text "If something went wrong try refreshing the page and re-joining the game by entering the same game code and using the same username."]
                    ]
                
                ]

          else
            div [ classList [ ( "help-dialog-button", True ), ( "small", isSmall ) ], onClick ToggleHelpDialog ]
                [ span [] [ text "?" ]
                ]
        ]
