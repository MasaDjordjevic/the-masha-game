port module Main exposing (..)

import Browser
import Game exposing (..)
import Json.Decode
import Json.Encode
import List
import Maybe
import State exposing (..)
import Time
import User exposing (..)
import View exposing (view)


defaultTimer =
    5



--- PORTS ----


port registerLocalUser : String -> Cmd msg


port localUserRegistered : (User -> msg) -> Sub msg


port openGameAdded : (Json.Decode.Value -> msg) -> Sub msg


port addGame : Json.Encode.Value -> Cmd msg


port requestToJoinGame : GameRequest -> Cmd msg


port acceptRequest : GameRequest -> Cmd msg


port gameChanged : (Json.Decode.Value -> msg) -> Sub msg


port changeGame : Json.Encode.Value -> Cmd msg


port addWord : Game.AddWord -> Cmd msg


port deleteWord : Game.DeleteWord -> Cmd msg



---- MODEL ----


init : ( Model, Cmd Msg )
init =
    ( { localUser = Maybe.Nothing
      , nameInput = ""
      , openGames = []
      , game = Maybe.Nothing
      , wordInput = ""
      , isOwner = False -- TODO: this should not be separate from the game or should be Maybe
      , turnTimer = 10
      }
    , Cmd.none
    )



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LocalUserRegistered user ->
            let
                gameThatBelongsToUser =
                    model.openGames |> List.filter (\game -> game.creator == user.name) |> List.head
            in
            ( { model | localUser = Just user, game = gameThatBelongsToUser }, Cmd.none )

        UpdateNameInput input ->
            ( { model | nameInput = input }, Cmd.none )

        UpdateWordInput input ->
            ( { model | wordInput = input }, Cmd.none )

        RegisterLocalUser ->
            ( model, registerLocalUser model.nameInput )

        OpenGameAdded value ->
            case Json.Decode.decodeValue gameDecoder value of
                Ok game ->
                    let
                        gameBelongsToUser =
                            case model.localUser of
                                Just usr ->
                                    game.creator == usr.name

                                Nothing ->
                                    False

                        newGame =
                            if gameBelongsToUser then
                                Just game

                            else
                                Nothing
                    in
                    ( { model | openGames = List.append model.openGames [ game ], game = newGame, isOwner = True }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        AddGame ->
            case model.localUser of
                Just user ->
                    let
                        newGame =
                            Game.createGameModel user
                    in
                    ( { model | game = Just newGame }
                      -- TODO: try removing this because it'll be update on openGameAdded
                    , newGame
                        |> Game.gameEncoder
                        |> addGame
                    )

                Nothing ->
                    ( model, Cmd.none )

        JoinGame game ->
            case model.localUser of
                Just user ->
                    ( { model | game = Just game }
                    , GameRequest game.id user
                        |> requestToJoinGame
                    )

                Nothing ->
                    ( model, Cmd.none )

        GameChanged value ->
            case Json.Decode.decodeValue gameDecoder value of
                Ok game ->
                    case model.game of
                        Just ownGame ->
                            let
                                newTimer =
                                    case game.turnTimer of
                                        Ticking ->
                                            model.turnTimer

                                        Game.NotTicking timerValue ->
                                            timerValue
                            in
                            if ownGame.id == game.id then
                                ( { model | game = Just game, turnTimer = newTimer }, Cmd.none )

                            else
                                ( model, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        AcceptUser user ->
            case model.game of
                Just game ->
                    if model.isOwner then
                        ( model
                        , GameRequest game.id user
                            |> acceptRequest
                        )

                    else
                        ( model, Cmd.none )

                Maybe.Nothing ->
                    ( model, Cmd.none )

        StartGame ->
            case model.game of
                Just game ->
                    if model.isOwner then
                        let
                            newGame =
                                { game | status = Game.Running }
                        in
                        ( model
                        , newGame
                            |> Game.gameEncoder
                            |> changeGame
                        )

                    else
                        ( model, Cmd.none )

                Maybe.Nothing ->
                    ( model, Cmd.none )

        State.AddWord ->
            case ( model.localUser, model.game ) of
                ( Just localUser, Just game ) ->
                    let
                        newWord =
                            Game.wordWithKey (Word model.wordInput localUser.name "")
                    in
                    ( { model | wordInput = "" }
                    , Game.AddWord game.id newWord
                        |> addWord
                    )

                ( _, _ ) ->
                    ( model, Cmd.none )

        NextRound ->
            case model.game of
                Just game ->
                    if model.isOwner then
                        let
                            newWords =
                                if game.round > 1 then
                                    restartWords game.state.words

                                else
                                    game.state.words

                            oldState =
                                game.state

                            newState =
                                { oldState | words = newWords }

                            newRound =
                                game.round + 1

                            gameWithNewRound =
                                { game | round = newRound, state = newState }

                            newGame =
                                if newRound == 1 then
                                    createTeams gameWithNewRound

                                else
                                    gameWithNewRound
                        in
                        ( model
                        , newGame
                            |> Game.gameEncoder
                            |> changeGame
                        )

                    else
                        ( model, Cmd.none )

                Maybe.Nothing ->
                    ( model, Cmd.none )

        State.DeleteWord id ->
            case model.game of
                Just game ->
                    ( model, deleteWord (Game.DeleteWord game.id id) )

                Nothing ->
                    ( model, Cmd.none )

        QuitGame ->
            case model.game of
                -- TODO: remove the player from the list of players or set to offline
                Just _ ->
                    ( { model | game = Maybe.Nothing }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        TimerTick _ ->
            case model.game of
                Just game ->
                    let
                        newTimerValue =
                            model.turnTimer - 1

                        cmd =
                            if newTimerValue < 0 && model.isOwner then
                                let
                                    newTeams =
                                        advanceCurrentTeam game.state.teams

                                    newWords =
                                        failCurrentWord game.state.words

                                    oldState =
                                        game.state

                                    newState =
                                        { oldState | teams = newTeams, words = newWords }

                                    newGame =
                                        { game | state = newState, turnTimer = Game.NotTicking defaultTimer }
                                in
                                newGame
                                    |> Game.gameEncoder
                                    |> changeGame

                            else
                                Cmd.none
                    in
                    ( { model | turnTimer = newTimerValue }, cmd )

                Nothing ->
                    ( model, Cmd.none )

        SwitchTimer ->
            case ( model.game, model.localUser ) of
                ( Just game, Just localUser ) ->
                    let
                        canSwitchTimer =
                            Game.canSwitchTimer game localUser

                        isTheBeginningOfExplaining =
                            case game.turnTimer of
                                Game.NotTicking timerValue ->
                                    timerValue == defaultTimer

                                Game.Ticking ->
                                    False

                        newWords =
                            if isTheBeginningOfExplaining then
                                succeedCurrentWord game.state.words

                            else
                                game.state.words

                        oldState =
                            game.state

                        newState =
                            { oldState | words = newWords }

                        newTurnTimer =
                            case game.turnTimer of
                                Game.NotTicking _ ->
                                    Game.Ticking

                                Game.Ticking ->
                                    Game.NotTicking model.turnTimer

                        newGame =
                            { game | turnTimer = newTurnTimer, state = newState }
                    in
                    if canSwitchTimer then
                        ( model
                        , newGame
                            |> Game.gameEncoder
                            |> changeGame
                        )

                    else
                        ( model, Cmd.none )

                ( _, _ ) ->
                    ( model, Cmd.none )

        WordGuessed ->
            case model.game of
                Just game ->
                    let
                        newWords =
                            succeedCurrentWord game.state.words

                        isRoundEnd =
                            List.isEmpty newWords.next

                        newGameTimer =
                            case game.turnTimer of
                                Ticking ->
                                    if isRoundEnd then
                                        Game.NotTicking model.turnTimer

                                    else
                                        game.turnTimer

                                Game.NotTicking _ ->
                                    game.turnTimer

                        oldState =
                            game.state

                        newTeams =
                            increaseCurrentTeamsScore game.state.teams

                        newState =
                            { oldState | words = newWords, teams = newTeams }

                        newGame =
                            { game | state = newState, turnTimer = newGameTimer }
                    in
                    ( model
                    , newGame
                        |> Game.gameEncoder
                        |> changeGame
                    )

                Nothing ->
                    ( model, Cmd.none )



---- SUBSCRIPTOINS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        timerSub =
            case model.game of
                Just game ->
                    case game.turnTimer of
                        Game.Ticking ->
                            Time.every 1000 TimerTick

                        Game.NotTicking _ ->
                            Sub.none

                Nothing ->
                    Sub.none
    in
    Sub.batch
        [ localUserRegistered LocalUserRegistered
        , openGameAdded OpenGameAdded
        , gameChanged GameChanged
        , timerSub
        ]



---- VIEW ----
---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
