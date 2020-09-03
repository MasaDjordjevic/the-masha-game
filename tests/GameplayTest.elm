module GameplayTest exposing (..)

import Dict
import Expect
import Game.Game exposing (Game, GameState, createGameModel, emptyGameState)
import Game.Gameplay exposing (isRoundEnd)
import Game.Participants exposing (Participants)
import Game.Status
import Game.Teams exposing (emptyTeams)
import Game.Words exposing (Word, Words)
import Test exposing (..)


suit : Test
suit =
    describe "Gameplay"
        [ test "isRoundEnd beggining" <|
            \_ ->
                let
                    testState =
                        GameState (Words [] Maybe.Nothing []) emptyTeams

                    testGame =
                        Game "" "playerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState -1 (Game.Game.NotTicking 5)
                in
                isRoundEnd testGame
                    |> Expect.equal True
        , test "isRoundEnd next not empty" <|
            \_ ->
                let
                    testState =
                        GameState (Words [] Maybe.Nothing [ Word "" "word" "p1" ]) emptyTeams

                    testGame =
                        Game "" "playerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState -1 (Game.Game.NotTicking 5)
                in
                isRoundEnd testGame
                    |> Expect.equal False
        , test "isRoundEnd current not empty" <|
            \_ ->
                let
                    testState =
                        GameState (Words [] (Just (Word "" "word" "p1")) []) emptyTeams

                    testGame =
                        Game "" "playerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState -1 (Game.Game.NotTicking 5)
                in
                isRoundEnd testGame
                    |> Expect.equal False
        , test "isRoundEnd yes" <|
            \_ ->
                let
                    testState =
                        GameState (Words [ Word "" "word" "p1" ] Maybe.Nothing []) emptyTeams

                    testGame =
                        Game "" "playerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState -1 (Game.Game.NotTicking 5)
                in
                isRoundEnd testGame
                    |> Expect.equal True
        ]
