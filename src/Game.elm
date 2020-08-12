module Game exposing (..)

import Dict
import Json.Decode exposing (Decoder, field)
import Json.Encode
import Player


type alias Game =
    { id : String
    , creator : String
    , status : GameStatus
    , players : List Player.Player
    }


type GameStatus
    = Open
    | Running
    | Finished


toString : GameStatus -> String
toString status =
    case status of
        Open ->
            "open"

        Running ->
            "running"

        Finished ->
            "finished"


createGameModel : String -> Game
createGameModel userName =
    Game "" userName Open []


gameDecoder : Decoder Game
gameDecoder =
    Json.Decode.map4 Game
        (field "id" Json.Decode.string)
        (field "creator" Json.Decode.string)
        (field "status" gameStatusDecoder)
        (Json.Decode.oneOf
            [ field "players" playersDecoder, Json.Decode.succeed [] ]
        )


maybePlayersToPlayers : Maybe (List Player.Player) -> List Player.Player
maybePlayersToPlayers players =
    case players of
        Just list ->
            list

        Nothing ->
            []


playersDecoder : Decoder (List Player.Player)
playersDecoder =
    Json.Decode.list Player.playerDecoder


gameStatusDecoder : Decoder GameStatus
gameStatusDecoder =
    Json.Decode.string
        |> Json.Decode.andThen gameStatusStringDecoder


gameStatusStringDecoder : String -> Decoder GameStatus
gameStatusStringDecoder stringStatus =
    case stringStatus of
        "open" ->
            Json.Decode.succeed Open

        "running" ->
            Json.Decode.succeed Running

        "finished" ->
            Json.Decode.succeed Finished

        _ ->
            Json.Decode.fail "game status unknown"


gameEncoder : Game -> Json.Encode.Value
gameEncoder game =
    Json.Encode.object
        [ ( "id", Json.Encode.string game.id )
        , ( "creator", Json.Encode.string game.creator )
        , ( "status", gameStatusEncoder game.status )
        , ( "players", Json.Encode.list Player.playerEncoder game.players )
        ]


gameStatusEncoder : GameStatus -> Json.Encode.Value
gameStatusEncoder status =
    status
        |> toString
        |> String.toLower
        |> Json.Encode.string
