module User exposing (..)

import Json.Decode exposing (Decoder, field)


type alias User =
    { id : String
    , name : String
    }


decodeUser : Decoder User
decodeUser =
    Json.Decode.map2 User
        (field "id" Json.Decode.string)
        (field "name" Json.Decode.string)
