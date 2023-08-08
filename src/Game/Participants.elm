module Game.Participants exposing (..)

import Dict exposing (Dict)
import Json.Decode exposing (Decoder, field, map2)
import Json.Encode
import Player exposing (Player, playerDecoder, playerEncoder)


type alias GameRequest =
    { gameId : String
    , user : Player
    }


type alias Participants =
    { players : Dict String Player
    , joinRequests : Dict String Player
    }


emptyParticipants : Participants
emptyParticipants =
    Participants Dict.empty Dict.empty


maybePlayersToPlayers : Maybe (List Player) -> List Player
maybePlayersToPlayers players =
    case players of
        Just list ->
            list

        Nothing ->
            []


playersDecoder : Decoder (Dict String Player)
playersDecoder =
    Json.Decode.dict playerDecoder


joinRequestsDecoder : Decoder (Dict String Player)
joinRequestsDecoder =
    Json.Decode.dict playerDecoder


participantsDecoder : Decoder Participants
participantsDecoder =
    Json.Decode.map2 Participants
        (Json.Decode.oneOf [ field "players" playersDecoder, Json.Decode.succeed Dict.empty ])
        (Json.Decode.oneOf [ field "joinRequests" joinRequestsDecoder, Json.Decode.succeed Dict.empty ])


participantsEncoder : Participants -> Json.Encode.Value
participantsEncoder participants =
    Json.Encode.object
        [ ( "players", Json.Encode.dict identity playerEncoder participants.players )
        , ( "joinRequests", Json.Encode.dict identity playerEncoder participants.joinRequests )
        ]
