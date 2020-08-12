module Player exposing (..)

import Json.Decode exposing (Decoder, field)
import Json.Encode


type alias Player =
    { userId : String
    , userName : String
    , status : PlayerStatus
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
    Json.Decode.map3 Player
        (field "userId" Json.Decode.string)
        (field "userName" Json.Decode.string)
        (field "status" playerStatusDecoder)


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
        [ ( "userId", Json.Encode.string player.userId )
        , ( "userName", Json.Encode.string player.userName )
        , ( "status", playerSatatusEncoder player.status )
        ]
