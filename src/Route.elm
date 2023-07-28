module Route exposing (..)

import Url
import Url.Parser exposing ((</>), Parser, parse, s, string)


type Route
    = Join String
    | Create
    | None


parseUrl : Url.Url -> Route
parseUrl url =
    case parse matchRoute url of
        Just route ->
            route

        Nothing ->
            None


matchRoute : Parser (Route -> a) a
matchRoute =
    Url.Parser.oneOf
        [ Url.Parser.map Join (s "join" </> string)
        , Url.Parser.map Create (s "create")
        ]
