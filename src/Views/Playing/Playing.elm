module Views.Playing.Playing exposing (..)

import Game.Game exposing (Game)
import Game.Gameplay exposing (isLocalPlayersTurn)
import Html exposing (Html, div, h1, h3, span, text)
import Html.Attributes exposing (class)
import State exposing (Model, Msg)
import User exposing (User)
import Views.Playing.CurrentWord exposing (currentWordView)
import Views.Playing.Info exposing (infoView)
import Views.Playing.Round exposing (roundView)
import Views.Playing.Teams exposing (teamsView)
import State exposing (PlayingGameModel)


playingNow : Game -> Html Msg
playingNow game =
    let
        teamOnTurn =
            game.state.teams.current

        score =
            teamOnTurn
                |> Maybe.map .score
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
        [ div [ class "team-on-turn" ]
            [ div [ class "explaining-player" ]
                [ span [] [ text explainingPlayer ]
                , span [] [ text "☝️" ]
                ]
            , div [ class "score-container" ]
                [ span [] [ text (String.fromInt score) ]
                , span [] [ text "POINTS" ]
                ]
            , guessingPlayers
            , span [ class "star-eyed-emoji" ] [ text "\u{1F929}" ]
            ]
        ]


playingView : PlayingGameModel -> Html Msg
playingView model =
    div [ class "playing-container" ]
        [ div [ class "playing-now" ]
            [ roundView model.game.state.round
            , currentWordView model.game model.localUser model.turnTimer
            , infoView model.game model.localUser model.turnTimer
            , playingNow model.game
            ]
        , teamsView model.game
        ]
