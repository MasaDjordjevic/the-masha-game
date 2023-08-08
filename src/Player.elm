module Player exposing (..)

import Json.Decode exposing (Decoder, field)
import Json.Encode


type alias Player =
    { id : String
    , name : String
    , status : PlayerStatus
    , isOwner : Bool
    }


type PlayerStatus
    = Online
    | Offline


isOnline : Player -> Bool
isOnline player =
    case player.status of
        Online ->
            True

        Offline ->
            False


playerDecoder : Decoder Player
playerDecoder =
    Json.Decode.map4 Player
        (field "id" Json.Decode.string)
        (field "name" Json.Decode.string)
        (field "status" playerStatusDecoder)
        (field "isOwner" Json.Decode.bool)


playerStatusDecoder : Decoder PlayerStatus
playerStatusDecoder =
    Json.Decode.string
        |> Json.Decode.andThen playerStatusStringDecoder


playerStatusStringDecoder : String -> Decoder PlayerStatus
playerStatusStringDecoder stringStatus =
    case stringStatus of
        "online" ->
            Json.Decode.succeed Online

        "offline" ->
            Json.Decode.succeed Offline

        _ ->
            Json.Decode.fail "player status unknown"


toString : PlayerStatus -> String
toString status =
    case status of
        Online ->
            "online"

        Offline ->
            "offline"


playerSatatusEncoder : PlayerStatus -> Json.Encode.Value
playerSatatusEncoder status =
    status
        |> toString
        |> Json.Encode.string


playerEncoder : Player -> Json.Encode.Value
playerEncoder player =
    Json.Encode.object
        [ ( "id", Json.Encode.string player.id )
        , ( "name", Json.Encode.string player.name )
        , ( "status", playerSatatusEncoder player.status )
        , ( "isOwner", Json.Encode.bool player.isOwner )
        ]
