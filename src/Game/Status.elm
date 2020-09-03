module Game.Status exposing (GameStatus(..), gameStatusDecoder, gameStatusEncoder, toString)

import Json.Decode exposing (Decoder, string)
import Json.Encode


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


gameStatusEncoder : GameStatus -> Json.Encode.Value
gameStatusEncoder status =
    status
        |> toString
        |> String.toLower
        |> Json.Encode.string


gameStatusDecoder : Decoder GameStatus
gameStatusDecoder =
    Json.Decode.string
        |> Json.Decode.andThen gameStatusStringDecoder
