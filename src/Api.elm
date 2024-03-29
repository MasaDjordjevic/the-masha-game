module Api exposing (..)

import Game.Game exposing (Game, gameDecoder)
import Game.Words exposing (Word, wordEncoder)
import Http
import Json.Decode
import Json.Encode
import Player exposing (Player, playerDecoder)
import State exposing (..)


deleteWord : String -> String -> String -> Cmd Msg
deleteWord apiUrl gameId wordId =
    Http.post
        { url = apiUrl ++ "/deleteWord"
        , body =
            Http.jsonBody <|
                Json.Encode.object
                    [ ( "gameId", Json.Encode.string gameId )
                    , ( "wordId", Json.Encode.string wordId )
                    ]
        , expect = Http.expectString NoOpResult
        }


addWord : String -> String -> Word -> Cmd Msg
addWord apiUrl gameId word =
    Http.post
        { url = apiUrl ++ "/addWord"
        , body =
            Http.jsonBody <|
                Json.Encode.object
                    [ ( "gameId", Json.Encode.string gameId )
                    , ( "word", wordEncoder word )
                    ]
        , expect = Http.expectString NoOpResult
        }


kickPlayer : String -> String -> String -> Cmd Msg
kickPlayer apiUrl userId gameId =
    Http.post
        { url = apiUrl ++ "/kickPlayer"
        , body =
            Http.jsonBody <|
                Json.Encode.object
                    [ ( "userId", Json.Encode.string userId )
                    , ( "gameId", Json.Encode.string gameId )
                    ]
        , expect = Http.expectString NoOpResult
        }


joinGame : String -> String -> String -> Cmd Msg
joinGame apiUrl gameId username =
    Http.post
        { url = apiUrl ++ "/joinGame"
        , body =
            Http.jsonBody <|
                Json.Encode.object
                    [ ( "gameId", Json.Encode.string gameId )
                    , ( "username", Json.Encode.string username )
                    ]
        , expect = Http.expectJson JoinedGame joinedGameResponseDecoder
        }


joinedGameResponseDecoder : Json.Decode.Decoder JoinedGameInfo
joinedGameResponseDecoder =
    Json.Decode.map3 JoinedGameInfo
        (Json.Decode.field "status" Json.Decode.string)
        (Json.Decode.field "player" playerDecoder)
        (Json.Decode.field "game" Game.Game.gameDecoder)


findGame : String -> String -> Cmd Msg
findGame apiUrl gameCode =
    Http.get
        { url = apiUrl ++ "/findGame?gameId=" ++ gameCode
        , expect = Http.expectJson GameFound gameDecoder
        }


addedGameResponseDecoder : Json.Decode.Decoder ( Game, Player )
addedGameResponseDecoder =
    Json.Decode.map2 Tuple.pair
        (Json.Decode.field "game" gameDecoder)
        (Json.Decode.field "player" playerDecoder)


createAddGameRequestBody : String -> Game -> Http.Body
createAddGameRequestBody username game =
    Http.jsonBody <|
        Json.Encode.object
            [ ( "game", Game.Game.gameEncoder game )
            , ( "username", Json.Encode.string username )
            ]


addGame : String -> String -> Game -> Cmd Msg
addGame apiUrl username game =
    Http.post
        { url = apiUrl ++ "/addGame"
        , body = createAddGameRequestBody username game
        , expect = Http.expectJson GameAdded addedGameResponseDecoder
        }
