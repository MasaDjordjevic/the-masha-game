module View exposing (openGameView, view)

import Dict exposing (Dict)
import Game exposing (Game, Word, Words)
import Html exposing (Html, button, div, h1, h2, h3, input, label, p, span, table, td, text, th, tr)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Player
import State exposing (..)
import User exposing (User)


localUserView : Model -> Html Msg
localUserView model =
    case model.localUser of
        Just user ->
            div []
                [ h3 [] [ text ("Welcome " ++ user.name) ]
                ]

        Maybe.Nothing ->
            div []
                [ h2 [] [ text "Welcome" ]
                , input [ type_ "text", placeholder "Enter your name here", value model.nameInput, onInput UpdateNameInput ] []
                , button [ onClick RegisterLocalUser ] [ text "Register" ]
                , p [] [ text "If you end up here again but you want to rejoin the game you've been playing just type the same name." ]
                ]


openGameView : Game -> Html Msg
openGameView game =
    let
        noPlayers =
            game.participants.players
                |> Dict.toList
                |> List.length
                |> String.fromInt
    in
    tr []
        [ td []
            [ text game.creator
            ]
        , td []
            [ text noPlayers
            ]
        , td [] [ button [ onClick (JoinGame game) ] [ text "Join" ] ]
        ]


openGamesView : Model -> Html Msg
openGamesView model =
    case model.localUser of
        Just _ ->
            let
                gamesList =
                    model.openGames
                        |> List.map openGameView
                        |> Html.tbody []
            in
            div [ class "lobby" ]
                [ table []
                    [ tr []
                        [ th [] [ text "created by" ]
                        , th [] [ text "#Players" ]
                        ]
                    , gamesList
                    ]
                ]

        Nothing ->
            text ""


requestView : Dict String User -> Bool -> Html Msg
requestView users isOwner =
    let
        reqs =
            users
                |> Dict.toList
                |> List.map
                    (\( _, user ) ->
                        div []
                            [ span [] [ text user.name ]
                            , if isOwner then
                                button [ onClick (AcceptUser user) ] [ text "accept" ]

                              else
                                text ""
                            ]
                    )
                |> div []
    in
    div []
        [ h3 [ class "requests" ] [ text "requests" ]
        , reqs
        ]


playersView : Dict String User -> Html Msg
playersView users =
    let
        players =
            users
                |> Dict.toList
                |> List.map
                    (\( _, user ) ->
                        span [ class "player-name" ] [ text user.name ]
                    )
                |> div []
    in
    div [ class "players" ]
        [ h3 [] [ text "players" ]
        , players
        ]


currentOpenGameView : Game -> Bool -> Html Msg
currentOpenGameView game isOwner =
    div [ class "current-game" ]
        [ h2 [] [ text "Selected game" ]
        , button [ onClick QuitGame ] [ text "Back to lobby" ]
        , div [ class "details", class "section" ]
            [ h3 [ class "status" ] [ span [] [ text "status" ], text (Game.toString game.status) ]
            , h3 [ class "creator" ] [ span [] [ text "creator" ], text game.creator ]
            , playersView game.participants.players
            , requestView game.participants.joinRequests isOwner
            ]
        , if isOwner then
            button [ onClick StartGame ] [ text "Start" ]

          else
            text ""
        ]


wordsStatisticsView : Game.Words -> Html Msg
wordsStatisticsView words =
    let
        wordsByPlayer =
            Game.wordsByPlayer words.next

        wordCountByPlayer =
            Dict.map (\_ wordsList -> List.length wordsList) wordsByPlayer

        stats =
            wordCountByPlayer
                |> Dict.toList
                |> List.map
                    (\( playerName, wordsCount ) ->
                        div []
                            [ span [] [ text (playerName ++ " - ") ]
                            , span [] [ text (String.fromInt wordsCount) ]
                            ]
                    )
                |> div []
    in
    div [ class "added-words" ]
        [ h3 [] [ text "All added words" ]
        , stats
        ]


localPlayersWords : Words -> Maybe User -> Html Msg
localPlayersWords words localUser =
    let
        localWords =
            case localUser of
                Just user ->
                    words.next
                        |> Game.wordsByPlayer
                        |> Dict.get user.name

                Nothing ->
                    Just []
    in
    case localWords of
        Nothing ->
            text ""

        Just wordsList ->
            div [ class "local-words" ]
                [ span [] [ text "Your words" ]
                , wordsList
                    |> List.map
                        (\{ id, word } ->
                            div []
                                [ span [] [ text word ]
                                , button [ onClick (DeleteWord id), class "destructive", class "descrete" ] [ text "Delete" ]
                                ]
                        )
                    |> div []
                ]


getRoundText : Int -> String
getRoundText round =
    case round of
        0 ->
            "Round Adding words"

        1 ->
            "Round 1: explaining with words"

        2 ->
            "Round 2: charades"

        3 ->
            "Round 3: one word"

        4 ->
            "The game has ended 🎉"

        _ ->
            "The game hasn't started yet. When all players are ready creator can start the game."


wordsRoundView : Model -> Html Msg
wordsRoundView model =
    case model.game of
        Just game ->
            div [ class "section" ]
                [ div [ class "word-input" ]
                    [ div []
                        [ label [ for "word" ] [ text "New word" ]
                        , input [ type_ "text", id "word", placeholder "e.g. table, mango, nudist", value model.wordInput, onInput UpdateWordInput ] []
                        ]
                    , button [ onClick AddWord ] [ text "Add" ]
                    ]
                , localPlayersWords game.state.words model.localUser
                , wordsStatisticsView game.state.words
                ]

        Maybe.Nothing ->
            text ""


roundView : Model -> Html Msg
roundView model =
    case model.game of
        Just game ->
            case game.round of
                0 ->
                    wordsRoundView model

                _ ->
                    text ""

        Nothing ->
            text ""


getTimerString : Game -> String
getTimerString game =
    case game.turnTimer of
        Game.Ticking ->
            "Pause"

        Game.NotTicking _ ->
            "Start"


lastGuessedWord : Game -> String
lastGuessedWord game =
    case List.head game.state.words.guessed of
        Just word ->
            word.word

        Nothing ->
            ""


runningGameView : Model -> Bool -> Html Msg
runningGameView model isOwner =
    case ( model.game, model.localUser ) of
        ( Just game, Just localUser ) ->
            let
                canSwitchTimer =
                    Game.canSwitchTimer game localUser
            in
            div []
                [ div [ class "current-game" ]
                    [ button [ onClick QuitGame, class "destructive" ] [ text "Quit game and go to lobby" ]
                    , h2 [] [ text "Selected game" ]
                    , div [ class "details", class "section" ]
                        [ h3 [ class "status" ] [ span [] [ text "status" ], text (Game.toString game.status) ]
                        , h3 [ class "creator" ] [ span [] [ text "creator" ], text game.creator ]
                        , playersView game.participants.players
                        ]
                    , h2 [] [ text (getRoundText game.round) ]
                    , roundView model
                    , scoreboardView model
                    , div [ class "timer", class "section" ]
                        [ h3 [] [ text ("Timer: " ++ String.fromInt model.turnTimer) ]
                        , if canSwitchTimer then
                            button [ onClick SwitchTimer ] [ text (getTimerString game) ]

                          else
                            text ""
                        ]
                    , if Game.isExplaining game localUser then
                        case game.state.words.current of
                            Just word ->
                                div [ class "guessing-container", class "section" ]
                                    [ h3 [] [ text word.word ]
                                    , button [ onClick WordGuessed ] [ text "Guessed ✓" ]
                                    ]

                            Nothing ->
                                div [ class "section" ]
                                    [ span [] [ text "It's your turn!!! Start the timer when you are ready" ]
                                    ]

                      else
                        div [ class "column" ]
                            [ span [] [ text "It's not your turn to explain. Once it is the words will show up here." ]
                            , span [] [ text ("Last guessed word: " ++ lastGuessedWord game) ]
                            ]
                    , if isOwner && (game.round < 1 || Game.isRoundEnd game) then
                        button [ onClick NextRound ] [ text "Next round" ]

                      else
                        text ""
                    ]
                ]

        ( _, _ ) ->
            text ""


scoreboardTeamView : Bool -> Game.Team -> Html Msg
scoreboardTeamView highlight { players, score } =
    let
        playersString =
            players
                |> List.map .name
                |> String.join " - "
    in
    div [ class "team" ]
        [ if highlight then
            span [ class "highlight" ] [ text "->" ]

          else
            span [] [ text "" ]
        , span [ class "player-name" ]
            [ text playersString ]
        , span
            []
            [ text (String.fromInt score ++ " points") ]
        ]


scoreboardView : Model -> Html Msg
scoreboardView model =
    case model.game of
        Just game ->
            let
                teams =
                    game.state.teams
            in
            div [ class "section" ]
                [ h3 [] [ text "Teams (in order of play)" ]
                , case teams.current of
                    Just currentTeam ->
                        scoreboardTeamView True currentTeam

                    Nothing ->
                        text ""
                , teams.next
                    |> List.map (scoreboardTeamView False)
                    |> div []
                ]

        Maybe.Nothing ->
            text ""


lobbyView : Model -> Html Msg
lobbyView model =
    case model.localUser of
        Just user ->
            let
                currentGame =
                    case model.game of
                        Just game ->
                            let
                                isOwner =
                                    user.name == game.creator
                            in
                            if game.status == Game.Open then
                                Just (currentOpenGameView game isOwner)

                            else if game.status == Game.Running then
                                Just (runningGameView model isOwner)

                            else
                                Just (text "weird game state")

                        Nothing ->
                            Maybe.Nothing
            in
            div []
                [ case currentGame of
                    Just currGame ->
                        currGame

                    Maybe.Nothing ->
                        openGamesView model
                ]

        Nothing ->
            text ""


view : Model -> Html Msg
view model =
    div []
        [ div [ class "header" ]
            [ h1 [] [ text "The Masha Game" ]
            , localUserView model
            ]
        , lobbyView model
        , if model.game == Maybe.Nothing && model.localUser /= Maybe.Nothing then
            button [ onClick AddGame ] [ text "Add Game" ]

          else
            text ""
        ]
