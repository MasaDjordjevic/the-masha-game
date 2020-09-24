module Fixtures.Teams exposing (..)

import Dict
import Game.Teams exposing (Team, Teams)
import User exposing (User)


testPlayers4 =
    Dict.fromList [ ( "1", User "1" "p1" ), ( "2", User "2" "p2" ), ( "2-1", User "2-1" "p21" ), ( "2-2", User "2-2" "p22" ) ]


testPlayers6 =
    Dict.fromList [ ( "1", User "1" "p1" ), ( "2", User "2" "p2" ), ( "2-1", User "2-1" "p21" ), ( "2-2", User "2-2" "p22" ), ( "3-1", User "3-1" "p31" ), ( "3-2", User "3-2" "p32" ) ]


testJoinRequests =
    Dict.fromList [ ( "3-1", User "3-1" "p31" ), ( "3-2", User "3-2" "p32" ) ]


defaultTestTeams =
    Teams (Just (Team [ User "1" "p1", User "2" "p2" ] 0)) [ Team [ User "2-1" "p21", User "2-2" "p22" ] 0, Team [ User "3-1" "p31", User "3-2" "p32" ] 0 ]
