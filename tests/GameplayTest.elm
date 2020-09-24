module GameplayTest exposing (..)

import Dict
import Expect
import Game.Game exposing (Game, GameState, TurnTimer(..), createGameModel, emptyGameState)
import Game.Gameplay exposing (canSwitchTimer, endOfExplaining, guessWord, isExplaining, isRoundEnd, nextRound, switchTimer)
import Game.Participants exposing (Participants)
import Game.Status
import Game.Teams exposing (Team, Teams, emptyTeams)
import Game.Words exposing (Word, Words)
import Html exposing (p)
import Test exposing (..)
import User exposing (User)


suit : Test
suit =
    describe "Gameplay" [ isRoundEndSuit, canSwitchTimerSuit, isExplainingSuit, endOfExplainingSuit, switchTimerSuit, guessWordSuit ]


isRoundEndSuit : Test
isRoundEndSuit =
    describe "isRoundEnd"
        [ test "isRoundEnd beggining" <|
            \_ ->
                let
                    testState =
                        GameState (Words [] Maybe.Nothing []) emptyTeams

                    testGame =
                        Game "" "playerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState -1 (Game.Game.NotTicking 5) 60
                in
                isRoundEnd testGame
                    |> Expect.equal True
        , test "isRoundEnd next not empty" <|
            \_ ->
                let
                    testState =
                        GameState (Words [] Maybe.Nothing [ Word "" "word" "p1" ]) emptyTeams

                    testGame =
                        Game "" "playerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState -1 (Game.Game.NotTicking 5) 60
                in
                isRoundEnd testGame
                    |> Expect.equal False
        , test "isRoundEnd current not empty" <|
            \_ ->
                let
                    testState =
                        GameState (Words [] (Just (Word "" "word" "p1")) []) emptyTeams

                    testGame =
                        Game "" "playerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState -1 (Game.Game.NotTicking 5) 60
                in
                isRoundEnd testGame
                    |> Expect.equal False
        , test "isRoundEnd yes" <|
            \_ ->
                let
                    testState =
                        GameState (Words [ Word "" "word" "p1" ] Maybe.Nothing []) emptyTeams

                    testGame =
                        Game "" "playerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState -1 (Game.Game.NotTicking 5) 60
                in
                isRoundEnd testGame
                    |> Expect.equal True
        ]


canSwitchTimerSuit : Test
canSwitchTimerSuit =
    describe "canSwitchTimer"
        [ test "canSwitchTimer onTurn" <|
            \_ ->
                let
                    testTeams =
                        Teams (Just (Team [ User "1" "p1", User "2" "p2" ] 0)) [ Team [ User "2-1" "p21", User "2-2" "p22" ] 10 ]

                    testState =
                        GameState (Words [] Maybe.Nothing []) testTeams

                    testGame =
                        Game "" "ownerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState -1 (Game.Game.NotTicking 5) 60

                    testUser =
                        User "1" "p1"
                in
                canSwitchTimer testGame testUser
                    |> Expect.equal True
        , test "canSwitchTimer onTurn second" <|
            \_ ->
                let
                    testTeams =
                        Teams (Just (Team [ User "1" "p1", User "2" "p2" ] 0)) [ Team [ User "2-1" "p21", User "2-2" "p22" ] 10 ]

                    testState =
                        GameState (Words [] Maybe.Nothing []) testTeams

                    testGame =
                        Game "" "ownerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState -1 (Game.Game.NotTicking 5) 60

                    testUser =
                        User "2" "p2"
                in
                canSwitchTimer testGame testUser
                    |> Expect.equal True
        , test "canSwitchTimer not onTurn" <|
            \_ ->
                let
                    testTeams =
                        Teams (Just (Team [ User "1" "p1", User "2" "p2" ] 0)) [ Team [ User "2-1" "p21", User "2-2" "p22" ] 10 ]

                    testState =
                        GameState (Words [] Maybe.Nothing []) testTeams

                    testGame =
                        Game "" "ownerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState -1 (Game.Game.NotTicking 5) 60

                    testUser =
                        User "2-1" "p21"
                in
                canSwitchTimer testGame testUser
                    |> Expect.equal False
        ]


isExplainingSuit : Test
isExplainingSuit =
    describe "isExplaining"
        [ test "isExplaining onTurn" <|
            \_ ->
                let
                    testTeams =
                        Teams (Just (Team [ User "1" "p1", User "2" "p2" ] 0)) [ Team [ User "2-1" "p21", User "2-2" "p22" ] 10 ]

                    testState =
                        GameState (Words [] Maybe.Nothing []) testTeams

                    testGame =
                        Game "" "ownerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState -1 (Game.Game.NotTicking 5) 60

                    testUser =
                        User "1" "p1"
                in
                isExplaining testGame testUser
                    |> Expect.equal True
        , test "isExplaining onTurn second" <|
            \_ ->
                let
                    testTeams =
                        Teams (Just (Team [ User "1" "p1", User "2" "p2" ] 0)) [ Team [ User "2-1" "p21", User "2-2" "p22" ] 10 ]

                    testState =
                        GameState (Words [] Maybe.Nothing []) testTeams

                    testGame =
                        Game "" "ownerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState -1 (Game.Game.NotTicking 5) 60

                    testUser =
                        User "2" "p2"
                in
                isExplaining testGame testUser
                    |> Expect.equal False
        , test "isExplaining not onTurn" <|
            \_ ->
                let
                    testTeams =
                        Teams (Just (Team [ User "1" "p1", User "2" "p2" ] 0)) [ Team [ User "2-1" "p21", User "2-2" "p22" ] 10 ]

                    testState =
                        GameState (Words [] Maybe.Nothing []) testTeams

                    testGame =
                        Game "" "ownerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState -1 (Game.Game.NotTicking 5) 60

                    testUser =
                        User "2-1" "p21"
                in
                isExplaining testGame testUser
                    |> Expect.equal False
        ]


nextRoundSuit : Test
nextRoundSuit =
    describe "nextRound"
        [ test "nextRound create teams before first round and after adding words" <|
            \_ ->
                let
                    testPlayers =
                        Dict.fromList [ ( "1", User "1" "p1" ), ( "2", User "2" "p2" ), ( "2-1", User "2-1" "p21" ), ( "2-2", User "2-2" "p22" ) ]

                    testState =
                        GameState (Words [] Maybe.Nothing []) emptyTeams

                    testGame =
                        Game "" "ownerName" Game.Status.Open (Participants testPlayers Dict.empty) testState 0 (Game.Game.NotTicking 5) 60
                in
                Expect.all
                    [ .current >> Expect.notEqual Maybe.Nothing
                    , .next
                        >> List.length
                        >> Expect.equal 1
                    , .next
                        >> List.map (.players >> List.length)
                        >> Expect.equal [ 2 ]
                    ]
                    (nextRound testGame).state.teams
        , test "nextRound do nothing at the beginning" <|
            \_ ->
                let
                    wordsList =
                        [ Word "a" "player1" "", Word "b" "player2" "", Word "c" "player1" "" ]

                    testTeams =
                        Teams (Just (Team [ User "1" "p1", User "2" "p2" ] 0)) [ Team [ User "2-1" "p21", User "2-2" "p22" ] 10 ]

                    testState =
                        GameState (Words [] Maybe.Nothing wordsList) testTeams

                    testGame =
                        Game "" "ownerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState -1 (Game.Game.NotTicking 5) 60

                    expectedGame =
                        { testGame | round = 0 }
                in
                nextRound testGame
                    |> Expect.equal expectedGame
        , test "nextRound restarts guessed words after explaining round" <|
            \_ ->
                let
                    wordsList =
                        [ Word "a" "player1" "", Word "b" "player2" "", Word "c" "player1" "" ]

                    testTeams =
                        Teams (Just (Team [ User "1" "p1", User "2" "p2" ] 0)) [ Team [ User "2-1" "p21", User "2-2" "p22" ] 10 ]

                    testState =
                        GameState (Words wordsList Maybe.Nothing []) testTeams

                    testGame =
                        Game "" "ownerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState 1 (Game.Game.NotTicking 60) 60
                in
                Expect.all
                    [ .teams
                        >> Expect.equal testTeams
                    , .words >> .guessed >> List.length >> Expect.equal 0
                    , .words
                        >> .current
                        >> Expect.equal Maybe.Nothing
                    , .words
                        >> .next
                        >> List.length
                        >> Expect.equal (List.length wordsList)
                    ]
                    (nextRound testGame).state
        ]


endOfExplainingSuit : Test
endOfExplainingSuit =
    describe "endOfExplaining"
        [ test "endOfExplaining standard " <|
            \_ ->
                let
                    wordsList =
                        [ Word "a" "player1" "", Word "b" "player2" "", Word "c" "player1" "" ]

                    testTeams =
                        Teams (Just (Team [ User "1" "p1", User "2" "p2" ] 0)) [ Team [ User "2-1" "p21", User "2-2" "p22" ] 10 ]

                    expectTeams =
                        Teams (Just (Team [ User "2-1" "p21", User "2-2" "p22" ] 10)) [ Team [ User "2" "p2", User "1" "p1" ] 0 ]

                    testState =
                        GameState (Words [] (Just (Word "d" "player2" "")) wordsList) testTeams

                    testGame =
                        Game "" "ownerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState 1 (Game.Game.NotTicking 60) 60

                    wordsExpectation =
                        \words ->
                            Expect.all
                                [ .current
                                    >> Expect.equal Maybe.Nothing
                                , .guessed
                                    >> Expect.equal []
                                , .next
                                    >> List.length
                                    >> Expect.equal 4
                                ]
                                words
                in
                Expect.all
                    [ .turnTimer
                        >> Expect.equal (Restarted 60)
                    , .state >> .words >> wordsExpectation
                    , .state
                        >> .teams
                        >> Expect.equal expectTeams
                    ]
                    (endOfExplaining testGame)
        ]


switchTimerSuit : Test
switchTimerSuit =
    describe "switchTimer"
        [ test "should pause if it's ticking" <|
            \_ ->
                let
                    testGame =
                        Game "" "ownerName" Game.Status.Open (Participants Dict.empty Dict.empty) Game.Game.emptyGameState 1 Game.Game.Ticking 60
                in
                switchTimer testGame 34
                    |> .turnTimer
                    |> Expect.equal (Game.Game.NotTicking 34)
        , test "should just continue if in the middle of explaining" <|
            \_ ->
                let
                    testGame =
                        Game "" "ownerName" Game.Status.Open (Participants Dict.empty Dict.empty) Game.Game.emptyGameState 1 (Game.Game.NotTicking 28) 60
                in
                switchTimer testGame 34
                    |> .turnTimer
                    |> Expect.equal Game.Game.Ticking
        , test "should start the timer in beginning of explaining" <|
            \_ ->
                let
                    testGame =
                        Game "" "ownerName" Game.Status.Open (Participants Dict.empty Dict.empty) Game.Game.emptyGameState 1 (Game.Game.Restarted 30) 60
                in
                switchTimer testGame 34
                    |> .turnTimer
                    |> Expect.equal Game.Game.Ticking
        , test "should set the current word at the beginning of explaining" <|
            \_ ->
                let
                    testState =
                        GameState (Words [] Maybe.Nothing [ Word "d" "player2" "" ]) Game.Teams.emptyTeams

                    testGame =
                        Game "" "ownerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState 1 (Game.Game.Restarted 30) 60
                in
                switchTimer testGame 34
                    |> .state
                    |> .words
                    |> .current
                    |> Expect.notEqual Maybe.Nothing
        ]


guessWordSuit : Test
guessWordSuit =
    describe "guessWord"
        [ test "guessWord standard" <|
            \_ ->
                let
                    wordsList =
                        [ Word "a" "player1" "", Word "b" "player2" "", Word "c" "player1" "" ]

                    testTeams =
                        Teams (Just (Team [ User "1" "p1", User "2" "p2" ] 0)) [ Team [ User "2-1" "p21", User "2-2" "p22" ] 10 ]

                    expectTeams =
                        Teams (Just (Team [ User "1" "p1", User "2" "p2" ] 3)) [ Team [ User "2-1" "p21", User "2-2" "p22" ] 10 ]

                    testState =
                        GameState (Words [] (Just (Word "d" "player2" "")) wordsList) testTeams

                    testGame =
                        Game "" "ownerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState 1 Game.Game.Ticking 60

                    wordsExpectation =
                        \words ->
                            Expect.all
                                [ .current
                                    >> Expect.notEqual Maybe.Nothing
                                , .guessed
                                    >> List.length
                                    >> Expect.equal 3
                                , .next
                                    >> Expect.equal []
                                ]
                                words
                in
                Expect.all
                    [ .turnTimer
                        >> Expect.equal Game.Game.Ticking
                    , .state >> .words >> wordsExpectation
                    , .state
                        >> .teams
                        >> Expect.equal expectTeams
                    ]
                    (testGame
                        |> guessWord 14
                        |> guessWord 14
                        |> guessWord 14
                    )
        , test "guessWord guess all" <|
            \_ ->
                let
                    wordsList =
                        [ Word "a" "player1" "", Word "b" "player2" "", Word "c" "player1" "" ]

                    testTeams =
                        Teams (Just (Team [ User "1" "p1", User "2" "p2" ] 0)) [ Team [ User "2-1" "p21", User "2-2" "p22" ] 10 ]

                    expectTeams =
                        Teams (Just (Team [ User "1" "p1", User "2" "p2" ] 4)) [ Team [ User "2-1" "p21", User "2-2" "p22" ] 10 ]

                    testState =
                        GameState (Words [] (Just (Word "d" "player2" "")) wordsList) testTeams

                    testGame =
                        Game "" "ownerName" Game.Status.Open (Participants Dict.empty Dict.empty) testState 1 Game.Game.Ticking 60

                    wordsExpectation =
                        \words ->
                            Expect.all
                                [ .current
                                    >> Expect.equal Maybe.Nothing
                                , .guessed
                                    >> List.length
                                    >> Expect.equal 4
                                , .next
                                    >> Expect.equal []
                                ]
                                words
                in
                Expect.all
                    [ .turnTimer
                        >> Expect.equal (Game.Game.NotTicking 14)
                    , .state >> .words >> wordsExpectation
                    , .state
                        >> .teams
                        >> Expect.equal expectTeams
                    ]
                    (testGame
                        |> guessWord 14
                        |> guessWord 14
                        |> guessWord 14
                        |> guessWord 14
                    )
        ]
