module Views.Playing.Playing exposing (..)

import Game.Game exposing (Game)
import Game.Gameplay exposing (isLocalPlayersTurn)
import Html exposing (Html, div, h1, h3, span, text)
import Html.Attributes exposing (class)
import State exposing (Model, Msg)
import User exposing (User)
import Views.Playing.Round exposing (roundView)


wordsLeft : Game -> Html Msg
wordsLeft game =
    let
        wordsLeftCount =
            case game.state.words.current of
                Just _ ->
                    1 + List.length game.state.words.next

                Nothing ->
                    List.length game.state.words.next
    in
    div [ class "info-container" ]
        [ h3 []
            [ text "Words left "
            ]
        , h1 [] [ text (String.fromInt wordsLeftCount) ]
        ]


timeLeft : Model -> Html Msg
timeLeft model =
    div [ class "info-container" ]
        [ h3 []
            [ text "Time left "
            ]
        , h1 [] [ text (String.fromInt model.turnTimer) ]
        ]


previousWord : Game -> User -> Html Msg
previousWord game localUser =
    let
        prevWord =
            List.head game.state.words.guessed

        isOnTurn =
            isLocalPlayersTurn game localUser
    in
    case ( prevWord, isOnTurn ) of
        ( Just word, True ) ->
            div [ class "info-container" ]
                [ h3 [] [ text "Previous word " ]
                , h1 [] [ text word.word ]
                ]

        ( _, _ ) ->
            text ""


playingNow : Game -> Html Msg
playingNow game =
    let
        teamOnTurn =
            game.state.teams.current

        score =
            Maybe.map (\team -> team.score) teamOnTurn
                |> Maybe.withDefault 0

        explainingPlayer =
            case teamOnTurn of
                Just currentTeam ->
                    currentTeam.players
                        |> List.head
                        |> Maybe.withDefault (User "" "n/a")
                        |> .name

                Nothing ->
                    "n/a"

        guessingPlayersNames =
            case teamOnTurn of
                Just currentTeam ->
                    currentTeam.players
                        |> List.drop 1
                        |> List.map .name

                Nothing ->
                    [ "n/a" ]

        guessingPlayers =
            guessingPlayersNames
                |> List.map (\name -> span [] [ text name ])
                |> div [ class "guessing-players" ]
    in
    div [ class "info-container", class "section" ]
        [ h3 [] [ text "Playing now" ]
        , div [ class "team-on-turn" ]
            [ div [ class "explaining-player" ]
                [ span [] [ text explainingPlayer ]
                , span [] [ text "☝️" ]
                ]
            , div [ class "score-container" ]
                [ span [] [ text "score" ]
                , span [] [ text (String.fromInt score) ]
                ]
            , guessingPlayers
            ]
        ]


playingView : Model -> Html Msg
playingView model =
    case ( model.game, model.localUser ) of
        ( Just game, Just localUser ) ->
            div [ class "playing-now-background " ]
                [ div [ class "playing-now" ]
                    [ roundView game.round
                    , div
                        [ class "turn-stats", class "section" ]
                        [ wordsLeft game
                        , previousWord game localUser
                        , timeLeft model
                        ]
                    , playingNow game
                    ]
                ]

        ( _, _ ) ->
            text ""
