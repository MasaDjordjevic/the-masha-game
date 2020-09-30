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
            div [ class "playing-container" ]
                [ div [ class "playing-now-background " ]
                    [ div [ class "playing-now" ]
                        [ roundView game.round
                        , currentWordView game localUser
                        , infoView game localUser model.turnTimer
                        , playingNow game
                        ]
                    ]
                , teamsView game
                ]

        ( _, _ ) ->
            text ""
