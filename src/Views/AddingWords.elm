module Views.AddingWords exposing (..)

import Dict exposing (Dict)
import Game.Game exposing (Game)
import Game.Words
import Html exposing (Html, button, div, h1, h3, input, span, text)
import Html.Attributes exposing (class, classList, id, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import State exposing (Msg(..), PlayingGameModel, UserRole(..))
import User exposing (User)


wordCounterList : Dict String User -> Bool -> Html Msg
wordCounterList users isOwner =
    users
        |> Dict.toList
        |> List.map
            (\( _, user ) ->
                div
                    [ classList
                        [ ( "space-between", isOwner )
                        , ( "request", True )
                        ]
                    ]
                    [ span [] [ text user.name ]
                    , if isOwner then
                        button [ class "icon-button", onClick (AcceptUser user) ] [ text "✔️" ]

                      else
                        text ""
                    ]
            )
        |> div [ class "participants" ]


wordsStatisticsView : Game.Words.Words -> Dict String User -> Html Msg
wordsStatisticsView words players =
    let
        wordCountByPlayer =
            Game.Words.wordsByPlayer words.next
                |> Dict.map (\_ wordsList -> List.length wordsList)

        allPlayers =
            players
                |> Dict.values
                |> List.map (\player -> ( player.name, 0 ))
                |> Dict.fromList

        statsData =
            Dict.union wordCountByPlayer allPlayers

        stats =
            statsData
                |> Dict.toList
                |> List.map
                    (\( playerName, wordsCount ) ->
                        div [ class "request", class "space-between" ]
                            [ span [] [ text playerName ]
                            , span [] [ text (String.fromInt wordsCount) ]
                            ]
                    )
                |> div []
    in
    div []
        [ div [ class "join-requests-container", class "words-stats-container" ]
            [ h3 []
                [ text "Players" ]
            , stats
            ]
        ]


localPlayersWords : Game.Words.Words -> User -> Html Msg
localPlayersWords words localUser =
    let
        localWords =
            words.next
                |> Game.Words.wordsByPlayer
                |> Dict.get localUser.name

        noWords =
            case localWords of
                Nothing ->
                    0

                Just wordsList ->
                    List.length wordsList
    in
    case localWords of
        Nothing ->
            text ""

        Just wordsList ->
            div [ class "local-words" ]
                [ h3 [] [ text ("Words added: " ++ String.fromInt noWords) ]
                , wordsList
                    |> List.map
                        (\{ id, word } ->
                            div [ class "space-between" ]
                                [ span [] [ text word ]
                                , button [ onClick (DeleteWord id), class "icon-button" ] [ span [] [ text "𝗫" ] ]
                                ]
                        )
                    |> div [ class "word-list" ]
                ]


wordsInputView : Game -> User -> String -> Html Msg
wordsInputView game localUser inputValue =
    div [ class "words-input-container" ]
        [ localPlayersWords game.state.words localUser
        , input [ type_ "text", id "word", placeholder "e.g. table, mango, nudist", value inputValue, onInput UpdateWordInput ] []
        , button [ onClick AddWord ] [ text "Add" ]
        ]


addingWordsView : PlayingGameModel -> Html Msg
addingWordsView model =
    let
        wordsInput =
            case model.localUser of
                LocalPlayer localPlayer ->
                    wordsInputView model.game localPlayer model.wordInput

                LocalWatcher _ ->
                    text ""
    in
    div [ class "adding-words-container" ]
        [ h1 []
            [ text "Let’s add some words" ]
        , div []
            [ wordsInput
            , wordsStatisticsView model.game.state.words model.game.participants.players
            , if model.isOwner then
                button [ onClick NextRound ] [ text "Let's play" ]

              else
                text ""
            ]
        ]
