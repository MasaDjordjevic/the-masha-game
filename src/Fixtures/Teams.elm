module Fixtures.Teams exposing (..)

import Dict
import Game.Teams exposing (Team, Teams)
import Player exposing (Player, PlayerStatus(..))


testPlayers4 =
    Dict.fromList [ ( "1", Player "1" "p1" Online True ), ( "2", Player "2" "p2" Online False ), ( "2-1", Player "2-1" "p21" Online False ), ( "2-2", Player "2-2" "p22" Online False ) ]


testPlayers6 =
    Dict.fromList [ ( "1", Player "1" "p1" Online True ), ( "2", Player "2" "p2" Online False ), ( "2-1", Player "2-1" "p21" Online False ), ( "2-2", Player "2-2" "p22" Online False ), ( "3-1", Player "3-1" "p31" Online False ), ( "3-2", Player "3-2" "p32" Online False ) ]


testJoinRequests =
    Dict.fromList [ ( "3-1", Player "3-1" "p31" Online False ), ( "3-2", Player "3-2" "p32" Online False ) ]


defaultTestTeams =
    Teams (Just (Team [ Player "1" "p1" Online True, Player "2" "p2" Online False ] 0)) [ Team [ Player "2-1" "p21" Online False, Player "2-2" "p22" Online False ] 0, Team [ Player "3-1" "p31" Online False, Player "3-2" "p32" Online False ] 0 ]
