module TeamsTest exposing (..)

import Dict
import Expect
import Game.Teams exposing (Team, Teams, advanceCurrentTeam, createTeams, getScoreboard, increaseCurrentTeamsScore, shiftTeamPlayers, teamToString)
import Test exposing (..)
import User exposing (User)


sortWithTeamName : Team -> Team -> Basics.Order
sortWithTeamName a b =
    Basics.compare (teamToString a.players) (teamToString b.players)


sortTeams : Teams -> Teams
sortTeams teams =
    Teams teams.current (List.sortWith sortWithTeamName teams.next)


suit : Test
suit =
    describe "Teams"
        [ test "shiftTeamPlayers with two players" <|
            \_ ->
                shiftTeamPlayers (Team [ User "1" "p1", User "2" "p2" ] 0)
                    |> Expect.equal (Team [ User "2" "p2", User "1" "p1" ] 0)
        , test "shiftTeamPlayers with three players" <|
            \_ ->
                shiftTeamPlayers (Team [ User "1" "p1", User "2" "p2", User "3" "p3" ] 0)
                    |> Expect.equal (Team [ User "2" "p2", User "3" "p3", User "1" "p1" ] 0)
        , test "advanceCurrentTeam" <|
            \_ ->
                advanceCurrentTeam (Teams (Just (Team [ User "1" "p1", User "2" "p2" ] 0)) [ Team [ User "2-1" "p21", User "2-2" "p22" ] 10 ])
                    |> Expect.equal (Teams (Just (Team [ User "2-1" "p21", User "2-2" "p22" ] 10)) [ Team [ User "2" "p2", User "1" "p1" ] 0 ])
        , test "advanceCurrentTeam empty" <|
            \_ ->
                advanceCurrentTeam (Teams Maybe.Nothing [ Team [ User "2-1" "p21", User "2-2" "p22" ] 10 ])
                    |> Expect.equal (Teams (Just (Team [ User "2-1" "p21", User "2-2" "p22" ] 10)) [])
        , test "increaseCurrentTeamsScore" <|
            \_ ->
                increaseCurrentTeamsScore (Teams (Just (Team [ User "1" "p1", User "2" "p2" ] 0)) [ Team [ User "2-1" "p21", User "2-2" "p22" ] 10 ])
                    |> Expect.equal (Teams (Just (Team [ User "1" "p1", User "2" "p2" ] 1)) [ Team [ User "2-1" "p21", User "2-2" "p22" ] 10 ])
        , test "createTeams" <|
            \_ ->
                let
                    teams =
                        createTeams (Dict.fromList [ ( "1", User "1" "p1" ), ( "2", User "2" "p2" ), ( "3", User "3" "p3" ), ( "4", User "4" "p4" ), ( "5", User "5" "p5" ), ( "6", User "6" "p6" ), ( "7", User "7" "p7" ), ( "8", User "8" "p8" ) ])
                in
                Expect.all
                    [ .current >> Expect.notEqual Maybe.Nothing
                    , .next
                        >> List.length
                        >> Expect.equal 3
                    , .next
                        >> List.map (.players >> List.length)
                        >> Expect.equal [ 2, 2, 2 ]
                    ]
                    teams
        , test "createTeams uneven" <|
            \_ ->
                let
                    teams =
                        createTeams (Dict.fromList [ ( "1", User "1" "p1" ), ( "2", User "2" "p2" ), ( "3", User "3" "p3" ), ( "4", User "4" "p4" ), ( "5", User "5" "p5" ), ( "6", User "6" "p6" ), ( "7", User "7" "p7" ), ( "8", User "8" "p8" ), ( "9", User "9" "p9" ) ])
                in
                Expect.all
                    [ .current >> Expect.notEqual Maybe.Nothing
                    , .next
                        >> List.length
                        >> Expect.equal 3
                    , .next
                        >> List.map (.players >> List.length)
                        >> Expect.equal [ 2, 2, 3 ]
                    ]
                    teams
        , test "getScoreboard" <|
            \_ ->
                let
                    teams =
                        Teams (Just (Team [ User "1" "p1", User "2" "p2" ] 15)) [ Team [ User "2-1" "p21", User "2-2" "p22" ] 10, Team [ User "3-1" "p31", User "3-2" "p32" ] 12 ]
                in
                getScoreboard teams
                    |> Expect.equal [ Team [ User "1" "p1", User "2" "p2" ] 15, Team [ User "3-1" "p31", User "3-2" "p32" ] 12, Team [ User "2-1" "p21", User "2-2" "p22" ] 10 ]
        ]
