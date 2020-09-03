module Game.Game exposing (..)

import Dict
import Game.Participants exposing (Participants, emptyParticipants, participantsDecoder, participantsEncoder)
import Game.Status exposing (GameStatus, gameStatusDecoder, gameStatusEncoder)
import Game.Teams exposing (Teams, emptyTeams, teamsDecoder, teamsEncoder)
import Game.Words exposing (Words, wordsDecoder, wordsEncoder)
import Json.Decode exposing (Decoder, field, int, map2, string)
import Json.Encode
import User exposing (User)


type alias Game =
    { id : String
    , creator : String
    , status : GameStatus
    , participants : Participants
    , state : GameState
    , round : Int
    , turnTimer : TurnTimer
    }


type TurnTimer
    = Ticking
    | NotTicking Int


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
    Game "" user.name Game.Status.Open userAsPlayer emptyGameState -1 (NotTicking 5)


gameDecoder : Decoder Game
gameDecoder =
    Json.Decode.map7 Game
        (field "id" Json.Decode.string)
        (field "creator" Json.Decode.string)
        (field "status" gameStatusDecoder)
        (Json.Decode.oneOf [ field "participants" participantsDecoder, Json.Decode.succeed emptyParticipants ])
        -- (field "state" gameStateDecoder)
        (Json.Decode.oneOf [ field "state" gameStateDecoder, Json.Decode.succeed emptyGameState ])
        (field "round" int)
        (field "turnTimer" turnTimerDecoder)


turnTimerDecoder : Decoder TurnTimer
turnTimerDecoder =
    Json.Decode.oneOf [ Json.Decode.bool |> Json.Decode.map (\_ -> Ticking), Json.Decode.int |> Json.Decode.map NotTicking ]


turnTimerEncoder : TurnTimer -> Json.Encode.Value
turnTimerEncoder turnTimer =
    case turnTimer of
        Ticking ->
            Json.Encode.bool True

        NotTicking timerValue ->
            Json.Encode.int timerValue


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
        ]
