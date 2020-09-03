module Game exposing (..)

import Dict exposing (Dict)
import Json.Decode exposing (Decoder, field, int, list, map2, map3, string)
import Json.Encode
import List
import Player exposing (Player)
import Random
import Random.List exposing (shuffle)
import User exposing (User)


decodeList : Decoder (List a) -> Decoder (List a)
decodeList listDecoder =
    Json.Decode.oneOf [ listDecoder, Json.Decode.succeed [] ]


type alias GameRequest =
    { gameId : String
    , user : User
    }


type alias Game =
    { id : String
    , creator : String
    , status : GameStatus
    , participants : Participants
    , state : GameState
    , round : Int
    , turnTimer : TurnTimer
    }


type TurnTimer
    = Ticking
    | NotTicking Int


type alias Participants =
    { players : Dict String User
    , joinRequests : Dict String User
    }


type alias Team =
    { players : List User
    , score : Int
    }


type alias GameState =
    { words : Words
    , teams : Teams
    }


emptyParticipants =
    Participants Dict.empty Dict.empty


type GameStatus
    = Open
    | Running
    | Finished


type alias Word =
    { word : String
    , player : String
    , id : String
    }


type alias Words =
    { guessed : List Word
    , current : Maybe Word
    , next : List Word
    }


wordDecoder : Decoder Word
wordDecoder =
    map3 Word
        (field "word" string)
        (field "player" string)
        (field "id" string)


wordEncoder : Word -> Json.Encode.Value
wordEncoder word =
    Json.Encode.object
        [ ( "word", Json.Encode.string word.word )
        , ( "player", Json.Encode.string word.player )
        , ( "id", Json.Encode.string word.id )
        ]


wordsDecoder : Decoder Words
wordsDecoder =
    let
        dictToValueList =
            Json.Decode.dict wordDecoder
                |> Json.Decode.map
                    (Dict.toList >> List.map Tuple.second)
    in
    map3 Words
        (Json.Decode.oneOf [ field "guessed" dictToValueList, Json.Decode.succeed [] ])
        (Json.Decode.oneOf [ field "current" (Json.Decode.maybe wordDecoder), Json.Decode.succeed Maybe.Nothing ])
        (Json.Decode.oneOf [ field "next" dictToValueList, Json.Decode.succeed [] ])


groupByPlayer : Word -> Dict String (List Word) -> Dict String (List Word)
groupByPlayer word wordsDict =
    Dict.update
        word.player
        (Maybe.map ((::) word) >> Maybe.withDefault [ word ] >> Just)
        wordsDict


wordsByPlayer : List Word -> Dict String (List Word)
wordsByPlayer =
    List.foldr groupByPlayer Dict.empty


wordToKey : Word -> String
wordToKey { word, player } =
    word ++ "-" ++ player


wordWithKey : Word -> Word
wordWithKey word =
    { word | id = wordToKey word }


wordsListEncoder : List Word -> Json.Encode.Value
wordsListEncoder list =
    list
        |> List.map wordWithKey
        |> List.map (\word -> ( word.id, wordEncoder word ))
        |> Json.Encode.object


wordsEncoder : Words -> Json.Encode.Value
wordsEncoder words =
    Json.Encode.object
        [ ( "guessed", wordsListEncoder words.guessed )
        , ( "current"
          , case words.current of
                Just word ->
                    wordEncoder word

                Nothing ->
                    Json.Encode.null
          )
        , ( "next", wordsListEncoder words.next )
        ]


emptyTeams =
    Teams Maybe.Nothing []


teamToString : List User -> String
teamToString team =
    team
        |> List.map .name
        |> String.join "-"


gameStateDecoder : Decoder GameState
gameStateDecoder =
    map2 GameState
        (Json.Decode.oneOf [ field "words" wordsDecoder, Json.Decode.succeed (Words [] Maybe.Nothing []) ])
        (Json.Decode.oneOf [ field "teams" teamsDecoder, Json.Decode.succeed emptyTeams ])


gameStateEncoder : GameState -> Json.Encode.Value
gameStateEncoder gameState =
    Json.Encode.object
        [ ( "words", wordsEncoder gameState.words )
        , ( "teams", teamsEncoder gameState.teams )
        ]


emptyGameState =
    GameState (Words [] Maybe.Nothing []) emptyTeams


toString : GameStatus -> String
toString status =
    case status of
        Open ->
            "open"

        Running ->
            "running"

        Finished ->
            "finished"


type alias AddWord =
    { gameId : String
    , word : Word
    }


type alias DeleteWord =
    { gameId : String
    , wordId : String
    }


createGameModel : User -> Game
createGameModel user =
    let
        players =
            Dict.fromList [ ( user.id, user ) ]

        userAsPlayer =
            Participants players Dict.empty
    in
    Game "" user.name Open userAsPlayer emptyGameState -1 (NotTicking 5)


gameDecoder : Decoder Game
gameDecoder =
    Json.Decode.map7 Game
        (field "id" Json.Decode.string)
        (field "creator" Json.Decode.string)
        (field "status" gameStatusDecoder)
        (Json.Decode.oneOf [ field "participants" participantsDecoder, Json.Decode.succeed emptyParticipants ])
        -- (field "state" gameStateDecoder)
        (Json.Decode.oneOf [ field "state" gameStateDecoder, Json.Decode.succeed emptyGameState ])
        (field "round" int)
        (field "turnTimer" turnTimerDecoder)


turnTimerDecoder : Decoder TurnTimer
turnTimerDecoder =
    Json.Decode.oneOf [ Json.Decode.bool |> Json.Decode.map (\_ -> Ticking), Json.Decode.int |> Json.Decode.map NotTicking ]


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


gameStatusDecoder : Decoder GameStatus
gameStatusDecoder =
    Json.Decode.string
        |> Json.Decode.andThen gameStatusStringDecoder


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


turnTimerEncoder : TurnTimer -> Json.Encode.Value
turnTimerEncoder turnTimer =
    case turnTimer of
        Ticking ->
            Json.Encode.bool True

        NotTicking timerValue ->
            Json.Encode.int timerValue


gameEncoder : Game -> Json.Encode.Value
gameEncoder game =
    Json.Encode.object
        [ ( "id", Json.Encode.string game.id )
        , ( "creator", Json.Encode.string game.creator )
        , ( "status", gameStatusEncoder game.status )
        , ( "participants", participantsEncoder game.participants )
        , ( "state", gameStateEncoder game.state )
        , ( "round", Json.Encode.int game.round )
        , ( "turnTimer", turnTimerEncoder game.turnTimer )
        ]


gameStatusEncoder : GameStatus -> Json.Encode.Value
gameStatusEncoder status =
    status
        |> toString
        |> String.toLower
        |> Json.Encode.string


type alias Teams =
    { current : Maybe Team
    , next : List Team
    }


teamsDecoder : Decoder Teams
teamsDecoder =
    Json.Decode.map2 Teams
        (Json.Decode.oneOf [ field "current" (Json.Decode.maybe teamDecoder), Json.Decode.succeed Maybe.Nothing ])
        (decodeList (field "next" (Json.Decode.list teamDecoder)))


teamsEncoder : Teams -> Json.Encode.Value
teamsEncoder teams =
    Json.Encode.object
        [ ( "current"
          , case teams.current of
                Just curr ->
                    teamEncoder curr

                Nothing ->
                    Json.Encode.null
          )
        , ( "next", Json.Encode.list teamEncoder teams.next )
        ]


teamDecoder : Decoder Team
teamDecoder =
    Json.Decode.map2 Team
        (decodeList (field "players" (Json.Decode.list User.decodeUser)))
        (field "score" Json.Decode.int)


teamEncoder : Team -> Json.Encode.Value
teamEncoder team =
    Json.Encode.object
        [ ( "players", Json.Encode.list User.userEncoder team.players )
        , ( "score", Json.Encode.int team.score )
        ]


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


addRequest : User -> Game -> Game
addRequest user oldGame =
    let
        newJoinRequests =
            oldGame.participants.joinRequests
                |> Dict.insert user.id user
    in
    { oldGame | participants = { players = oldGame.participants.players, joinRequests = newJoinRequests } }


partitionBy2 : List a -> List (List a)
partitionBy2 list =
    case List.take 2 list of
        [] ->
            []

        head ->
            case List.drop 2 list of
                [ _ ] ->
                    [ List.take 3 list ]

                _ ->
                    head :: partitionBy2 (List.drop 2 list)


createTeams : Game -> Game
createTeams game =
    let
        playersList =
            game.participants.players
                |> Dict.toList
                |> List.map Tuple.second

        ( shuffledPlayers, _ ) =
            Random.step (shuffle playersList) (Random.initialSeed 0)

        groupsOfTwo =
            partitionBy2 shuffledPlayers

        teams =
            List.map (\group -> Team group 0) groupsOfTwo

        currentTeam =
            List.head teams

        nextTeams =
            List.drop 1 teams

        oldGameState =
            game.state
    in
    { game | state = { oldGameState | teams = Teams currentTeam nextTeams } }


shiftTeamPlayers : Team -> Team
shiftTeamPlayers team =
    let
        newPlayers =
            case team.players of
                first :: rest ->
                    rest ++ [ first ]

                a ->
                    a
    in
    { team | players = newPlayers }


failCurrentWord : Words -> Words
failCurrentWord words =
    let
        newNextWords =
            case words.current of
                Just currentWord ->
                    currentWord :: words.next

                Maybe.Nothing ->
                    words.next

        ( shuffledNextWords, _ ) =
            Random.step (shuffle newNextWords) (Random.initialSeed 0)
    in
    Words words.guessed Maybe.Nothing shuffledNextWords


succeedCurrentWord : Words -> Words
succeedCurrentWord words =
    let
        guessedWords =
            case words.current of
                Just currentWord ->
                    currentWord :: words.guessed

                Nothing ->
                    words.guessed

        newCurrentWord =
            List.head words.next

        ( shuffledNextWords, _ ) =
            Random.step (shuffle (List.drop 1 words.next)) (Random.initialSeed 0)
    in
    Words guessedWords newCurrentWord shuffledNextWords


restartWords : Words -> Words
restartWords words =
    let
        ( shuffledGuessedWords, _ ) =
            Random.step (shuffle words.guessed) (Random.initialSeed 0)
    in
    Words [] Maybe.Nothing shuffledGuessedWords


isRoundEnd : Game -> Bool
isRoundEnd game =
    case game.state.words.current of
        Just _ ->
            Basics.True

        Nothing ->
            List.isEmpty game.state.words.next


advanceCurrentTeam : Teams -> Teams
advanceCurrentTeam teams =
    let
        shiftedCurrentTeam =
            case teams.current of
                Just currentTeam ->
                    Just (shiftTeamPlayers currentTeam)

                Nothing ->
                    Maybe.Nothing

        nextTeam =
            List.head teams.next

        restTeams =
            List.drop 1 teams.next

        newNextTeams =
            case shiftedCurrentTeam of
                Just currTeam ->
                    restTeams ++ [ currTeam ]

                Nothing ->
                    restTeams
    in
    Teams nextTeam newNextTeams


canSwitchTimer : Game -> User.User -> Bool
canSwitchTimer game user =
    let
        teamOnTurn =
            game.state.teams.current

        isLocalPlayersTurn =
            case teamOnTurn of
                Just currentTeam ->
                    List.member user currentTeam.players

                Nothing ->
                    False

        isOwner =
            game.creator == user.name
    in
    isOwner || isLocalPlayersTurn


isExplaining : Game -> User.User -> Basics.Bool
isExplaining game user =
    let
        teamOnTurn =
            game.state.teams.current
    in
    case teamOnTurn of
        Just currentTeam ->
            case List.head currentTeam.players of
                Just explainingUser ->
                    explainingUser.id == user.id

                Nothing ->
                    False

        Nothing ->
            False


increaseCurrentTeamsScore : Teams -> Teams
increaseCurrentTeamsScore teams =
    let
        newCurrentTeam =
            case teams.current of
                Just oldCurrTeam ->
                    Just { oldCurrTeam | score = oldCurrTeam.score + 1 }

                Nothing ->
                    Maybe.Nothing
    in
    { teams | current = newCurrentTeam }
