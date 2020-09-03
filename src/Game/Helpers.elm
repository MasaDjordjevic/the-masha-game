module Game.Helpers exposing (decodeList)

import Json.Decode exposing (Decoder)


decodeList : Decoder (List a) -> Decoder (List a)
decodeList listDecoder =
    Json.Decode.oneOf [ listDecoder, Json.Decode.succeed [] ]
