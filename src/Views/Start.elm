module Views.Start exposing (..)

import Html exposing (Html, button, div, h1, h2, h3, img, input, p, span, text)
import Html.Attributes exposing (class, classList, src, type_, value)
import Html.Events exposing (onClick, onInput)
import State exposing (Errors, InitialGameModel, Msg(..))


gameNotFoundView : Errors -> Html Msg
gameNotFoundView errors =
    case List.head errors of
        Just error ->
            h3 [ class "error" ] [ text error ]

        Nothing ->
            text ""


startView : InitialGameModel -> Errors -> Html Msg
startView model erros =
    let
        slideToShow =
            modBy 6 model.instructionSlideNumber
    in
    div [ class "start-game-container" ]
        [ div []
            [ span [ class "confetti", class "mirrored" ] [ text "🎉" ]
            , span [ class "pre-title" ] [ text " Time to party, time for " ]
            , span [ class "confetti" ] [ text "🎉" ]
            ]
        , div []
            [ h1 [ class "title-large" ] [ text "THE MASHA GAME" ]
            ]

        -- , span [ class "or" ] [ text "OR" ]
        -- , div [ class "join" ]
        --     [ h2 [] [ text "ENTER WITH GAME PIN" ]
        --     , input [ type_ "text", value model.pinInput, onInput UpdatePinInput ] []
        --     , gameNotFoundView erros
        --     , button [ onClick EnterGame ] [ text "Enter" ]
        --     ]
        -- , h2 [ class "title-how-to-play" ] [ text "How to play ⬇" ]
        , div [ class "how-to-play" ]
            [ div [ classList [ ( "show", slideToShow == 1 ) ] ]
                [ img [ src "assets/stickman-call.png" ] []
                , h3 [] [ text "1. Gather in a call" ]
                , p [] [ text "Invite your friends to a call (e.g. Discord, Zoom, Meet)" ]
                ]
            , div [ classList [ ( "show", slideToShow == 2 ) ] ]
                [ img [ src "assets/stickman-writing2.png" ] []
                , h3 [] [ text "2. Write some words" ]
                , p [] [ text "Write words that your friends will guess during the game" ]
                ]
            , div [ classList [ ( "show", slideToShow == 3 ) ] ]
                [ img [ src "assets/stickman-teams2.png" ] []
                , h3 [] [ text "3. Start Playing" ]
                , p [] [ text "You will be divided into pairs" ]
                ]
            , div [ classList [ ( "show", slideToShow == 4 ) ] ]
                [ img [ src "assets/stickman-explaining.png" ] []
                , h3 [] [ text "4. Describe the word" ]
                , p [] [ text "Explain as many words as you can to your teammate (there is no skipping!)" ]
                ]
            , div [ classList [ ( "show", slideToShow == 5 ) ] ]
                [ img [ src "assets/stickman-learning2.png" ] []
                , h3 [] [ text "5. Next rounds" ]
                , p [] [ text "Remember all the words! They will be used in all rounds. Next up: Charades" ]
                ]
            , div [ classList [ ( "show", slideToShow == 0 ) ] ]
                [ img [ src "assets/stickman-one-word.png" ] []
                , h3 [] [ text "6. Describe with ONE word" ]
                , p [] [ text "It might seem too hard but you remember the words, right?" ]
                ]
            , div [ class "bars" ]
                [ div [ classList [ ( "animate", slideToShow == 1 ) ] ] []
                , div [ classList [ ( "animate", slideToShow == 2 ) ] ] []
                , div [ classList [ ( "animate", slideToShow == 3 ) ] ] []
                , div [ classList [ ( "animate", slideToShow == 4 ) ] ] []
                , div [ classList [ ( "animate", slideToShow == 5 ) ] ] []
                , div [ classList [ ( "animate", slideToShow == 0 ) ] ] []
                ]
            , button
                [ class "create-btn", onClick SetCreatingGameMode ]
                [ text "Create new game" ]
            ]
        ]
