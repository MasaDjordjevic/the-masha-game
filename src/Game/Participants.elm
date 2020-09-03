module Game.Participants exposing (..)

import Dict exposing (Dict)
import Json.Decode exposing (Decoder, field, int, list, map2, map3, string)
import Json.Encode
import Player exposing (Player)
import Random.List exposing (shuffle)
import User exposing (User)


type alias GameRequest =
    { gameId : String
    , user : User
    }


type alias Participants =
    { players : Dict String User
    , joinRequests : Dict String User
    }


emptyParticipants =
    Participants Dict.empty Dict.empty


maybePlayersToPlayers : Maybe (List Player.Player) -> List Player.Player
maybePlayersToPlayers players =
    case players of
        Just list ->
            list

        Nothing ->
            []


playersDecoder : Decoder (Dict String User)
playersDecoder =
    Json.Decode.dict User.decodeUser


joinRequestsDecoder : Decoder (Dict String User)
joinRequestsDecoder =
    Json.Decode.dict User.decodeUser


participantsDecoder : Decoder Participants
participantsDecoder =
    Json.Decode.map2 Participants
        (Json.Decode.oneOf [ field "players" playersDecoder, Json.Decode.succeed Dict.empty ])
        (Json.Decode.oneOf [ field "joinRequests" joinRequestsDecoder, Json.Decode.succeed Dict.empty ])


participantsEncoder : Participants -> Json.Encode.Value
participantsEncoder participants =
    Json.Encode.object
        [ ( "players", Json.Encode.dict identity User.userEncoder participants.players )
        , ( "joinRequests", Json.Encode.dict identity User.userEncoder participants.joinRequests )
        ]
