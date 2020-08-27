module User exposing (..)

import Json.Decode exposing (Decoder, field)
import Json.Encode


type alias User =
    { id : String
    , name : String
    }


decodeUser : Decoder User
decodeUser =
    Json.Decode.map2 User
        (field "id" Json.Decode.string)
        (field "name" Json.Decode.string)


userEncoder : User -> Json.Encode.Value
userEncoder user =
    Json.Encode.object
        [ ( "id", Json.Encode.string user.id )
        , ( "name", Json.Encode.string user.name )
        ]
