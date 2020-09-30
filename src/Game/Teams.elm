module Game.Teams exposing (..)

import Dict exposing (Dict)
import Game.Helpers exposing (decodeList)
import Json.Decode exposing (Decoder, field, int, list, map2, map3, string)
import Json.Encode
import Player exposing (Player)
import Random
import Random.List exposing (shuffle)
import User exposing (User)


type alias Team =
    { players : List User
    , score : Int
    }


type alias Teams =
    { current : Maybe Team
    , next : List Team
    }


emptyTeams =
    Teams Maybe.Nothing []


teamToString : List User -> String
teamToString team =
    team
        |> List.map .name
        |> String.join "-"


teamsDecoder : Decoder Teams
teamsDecoder =
    Json.Decode.map2 Teams
        (Json.Decode.oneOf [ field "current" (Json.Decode.maybe teamDecoder), Json.Decode.succeed Maybe.Nothing ])
        (decodeList (field "next" (Json.Decode.list teamDecoder)))


teamsEncoder : Teams -> Json.Encode.Value
teamsEncoder teams =
    Json.Encode.object
        [ ( "current"
          , case teams.current of
                Just curr ->
                    teamEncoder curr

                Nothing ->
                    Json.Encode.null
          )
        , ( "next", Json.Encode.list teamEncoder teams.next )
        ]


teamDecoder : Decoder Team
teamDecoder =
    Json.Decode.map2 Team
        (decodeList (field "players" (Json.Decode.list User.decodeUser)))
        (field "score" Json.Decode.int)


teamEncoder : Team -> Json.Encode.Value
teamEncoder team =
    Json.Encode.object
        [ ( "players", Json.Encode.list User.userEncoder team.players )
        , ( "score", Json.Encode.int team.score )
        ]


shiftTeamPlayers : Team -> Team
shiftTeamPlayers team =
    let
        newPlayers =
            case team.players of
                first :: rest ->
                    rest ++ [ first ]

                a ->
                    a
    in
    { team | players = newPlayers }


advanceCurrentTeam : Teams -> Teams
advanceCurrentTeam teams =
    let
        shiftedCurrentTeam =
            case teams.current of
                Just currentTeam ->
                    Just (shiftTeamPlayers currentTeam)

                Nothing ->
                    Maybe.Nothing

        nextTeam =
            List.head teams.next

        restTeams =
            List.drop 1 teams.next

        newNextTeams =
            case shiftedCurrentTeam of
                Just currTeam ->
                    restTeams ++ [ currTeam ]

                Nothing ->
                    restTeams
    in
    Teams nextTeam newNextTeams


increaseCurrentTeamsScore : Teams -> Teams
increaseCurrentTeamsScore teams =
    let
        newCurrentTeam =
            case teams.current of
                Just oldCurrTeam ->
                    Just { oldCurrTeam | score = oldCurrTeam.score + 1 }

                Nothing ->
                    Maybe.Nothing
    in
    { teams | current = newCurrentTeam }


partitionBy2 : List a -> List (List a)
partitionBy2 list =
    case List.take 2 list of
        [] ->
            []

        head ->
            case List.drop 2 list of
                [ _ ] ->
                    [ List.take 3 list ]

                _ ->
                    head :: partitionBy2 (List.drop 2 list)


createTeams : Dict String User -> Teams
createTeams players =
    let
        playersList =
            players
                |> Dict.toList
                |> List.map Tuple.second

        ( shuffledPlayers, _ ) =
            Random.step (shuffle playersList) (Random.initialSeed 0)

        groupsOfTwo =
            partitionBy2 shuffledPlayers

        teams =
            List.map (\group -> Team group 0) groupsOfTwo

        currentTeam =
            List.head teams

        nextTeams =
            List.drop 1 teams
    in
    Teams currentTeam nextTeams


getScoreboard : Teams -> List Team
getScoreboard teams =
    Maybe.map List.singleton teams.current
        |> Maybe.withDefault []
        |> List.append teams.next
        |> List.sortBy .score
        |> List.reverse
