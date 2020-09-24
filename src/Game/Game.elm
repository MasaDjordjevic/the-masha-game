module Game.Game exposing (..)

import Dict
import Game.Participants exposing (Participants, emptyParticipants, participantsDecoder, participantsEncoder)
import Game.Status exposing (GameStatus, gameStatusDecoder, gameStatusEncoder)
import Game.Teams exposing (Teams, emptyTeams, teamsDecoder, teamsEncoder)
import Game.Words exposing (Words, wordsDecoder, wordsEncoder)
import Json.Decode exposing (Decoder, field, int, map2, string)
import Json.Encode
import User exposing (User)


defaultTimer =
    60


type alias Game =
    { id : String
    , creator : String
    , status : GameStatus
    , participants : Participants
    , state : GameState
    , round : Int
    , turnTimer : TurnTimer
    , defaultTimer : Int
    }


type TurnTimer
    = Ticking
    | NotTicking Int
    | Restarted Int


type alias GameState =
    { words : Words
    , teams : Teams
    }


gameStateDecoder : Decoder GameState
gameStateDecoder =
    map2 GameState
        (Json.Decode.oneOf [ field "words" wordsDecoder, Json.Decode.succeed (Words [] Maybe.Nothing []) ])
        (Json.Decode.oneOf [ field "teams" teamsDecoder, Json.Decode.succeed emptyTeams ])


gameStateEncoder : GameState -> Json.Encode.Value
gameStateEncoder gameState =
    Json.Encode.object
        [ ( "words", wordsEncoder gameState.words )
        , ( "teams", teamsEncoder gameState.teams )
        ]


emptyGameState : GameState
emptyGameState =
    GameState (Words [] Maybe.Nothing []) emptyTeams


createGameModel : User -> Game
createGameModel user =
    let
        players =
            Dict.fromList [ ( user.id, user ) ]

        userAsPlayer =
            Participants players Dict.empty
    in
    Game "" user.name Game.Status.Open userAsPlayer emptyGameState -1 (Restarted defaultTimer) defaultTimer


gameDecoder : Decoder Game
gameDecoder =
    Json.Decode.map8 Game
        (field "id" Json.Decode.string)
        (field "creator" Json.Decode.string)
        (field "status" gameStatusDecoder)
        (Json.Decode.oneOf [ field "participants" participantsDecoder, Json.Decode.succeed emptyParticipants ])
        -- (field "state" gameStateDecoder)
        (Json.Decode.oneOf [ field "state" gameStateDecoder, Json.Decode.succeed emptyGameState ])
        (field "round" int)
        (field "turnTimer" turnTimerDecoder)
        (field "defaultTimer" int)


turnTimerDecoder : Decoder TurnTimer
turnTimerDecoder =
    field "status" Json.Decode.string
        |> Json.Decode.andThen turnTimerTypeDecoder


turnTimerTypeDecoder : String -> Decoder TurnTimer
turnTimerTypeDecoder timerType =
    case timerType of
        "ticking" ->
            Json.Decode.succeed Ticking

        "paused" ->
            field "value" Json.Decode.int |> Json.Decode.map NotTicking

        "restarted" ->
            field "value" Json.Decode.int |> Json.Decode.map Restarted

        _ ->
            Json.Decode.succeed (NotTicking 0)



-- Json.Decode.oneOf
-- [ Json.Decode.bool |> Json.Decode.map (\_ -> Ticking), Json.Decode.int |> Json.Decode.map NotTicking ]


turnTimerEncoder : TurnTimer -> Json.Encode.Value
turnTimerEncoder turnTimer =
    case turnTimer of
        Ticking ->
            Json.Encode.object [ ( "status", Json.Encode.string "ticking" ) ]

        NotTicking timerValue ->
            Json.Encode.object [ ( "status", Json.Encode.string "paused" ), ( "value", Json.Encode.int timerValue ) ]

        Restarted timerValue ->
            Json.Encode.object [ ( "status", Json.Encode.string "restarted" ), ( "value", Json.Encode.int timerValue ) ]


gameEncoder : Game -> Json.Encode.Value
gameEncoder game =
    Json.Encode.object
        [ ( "id", Json.Encode.string game.id )
        , ( "creator", Json.Encode.string game.creator )
        , ( "status", gameStatusEncoder game.status )
        , ( "participants", participantsEncoder game.participants )
        , ( "state", gameStateEncoder game.state )
        , ( "round", Json.Encode.int game.round )
        , ( "turnTimer", turnTimerEncoder game.turnTimer )
        , ( "defaultTimer", Json.Encode.int game.defaultTimer )
        ]
