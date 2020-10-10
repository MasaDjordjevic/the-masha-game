module Views.Playing.Teams exposing (..)

import Game.Game exposing (Game)
import Game.Teams exposing (Team, getScoreboard)
import Html exposing (Html, div, h2, h3, h4, span, text)
import Html.Attributes exposing (class)
import State exposing (Msg)


teamView : Int -> Team -> Html Msg
teamView indexNumber team =
    div [ class "team-container" ]
        [ h4 [] [ text ("Team " ++ String.fromInt indexNumber) ]
        , teamPlayers team
        , h4 [] [ text ("Score " ++ String.fromInt team.score) ]
        ]


teamPlayers : Team -> Html Msg
teamPlayers team =
    team.players
        |> List.map
            (\user ->
                h2 [] [ text user.name ]
            )
        |> span []


teamsView : Game -> Html Msg
teamsView game =
    div [ class "scoreboard-container" ]
        [ h3 [] [ text "the teams" ]
        , getScoreboard game.state.teams
            |> List.indexedMap teamView
            |> div []
        ]
