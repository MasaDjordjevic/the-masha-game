port module Main exposing (..)

import Api
import Browser
import Browser.Navigation as Nav
import Constants exposing (defaultTimer)
import Debugger.Update
import Delay
import Dict
import Game.Game exposing (..)
import Game.Gameplay
import Game.Participants
import Game.Words exposing (Word)
import Json.Decode
import Json.Encode
import Route
import State exposing (Flags, GameModel(..), Model, Msg(..), UserRole(..))
import Time
import Url
import User exposing (..)
import Views.View exposing (view)


devApiUrl : String
devApiUrl =
    "http://localhost:5001/themashagame-990a8/us-central1"



--- PORTS ----


port subscribeToGame : Json.Encode.Value -> Cmd msg


port gameChanged : (Json.Decode.Value -> msg) -> Sub msg


port changeGame : Json.Encode.Value -> Cmd msg


port copyInviteLink : Json.Encode.Value -> Cmd msg



---- MODEL ----


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        route =
            Route.parseUrl url

        apiUrl =
            if flags.environment == "development" then
                devApiUrl

            else
                ""
    in
    ( { currentGame =
            case route of
                Route.Join _ ->
                    LoadingGameToJoin { nameInput = "" }

                _ ->
                    Initial { pinInput = "" }
      , environment = flags.environment
      , apiUrl = apiUrl
      , errors = []
      , isHelpDialogOpen = False
      , isDonateDialogOpen = False
      , url = url
      , route = route
      , navKey = navKey
      }
    , case route of
        Route.Join gameCode ->
            Api.findGame apiUrl gameCode

        _ ->
            Cmd.none
    )


playingGameUpdate : Msg -> Model -> ( Model, Cmd Msg )
playingGameUpdate msg model =
    case model.currentGame of
        Playing gameModel ->
            case gameModel.localUser of
                LocalPlayer localUser ->
                    let
                        game =
                            gameModel.game
                    in
                    case msg of
                        UpdateWordInput input ->
                            ( { model | currentGame = Playing { gameModel | wordInput = String.toUpper input } }, Cmd.none )

                        AddWord ->
                            if String.isEmpty gameModel.wordInput then
                                ( model, Cmd.none )

                            else
                                let
                                    isPlayer =
                                        Dict.member localUser.id game.participants.players

                                    newWord =
                                        Game.Words.wordWithKey 0 (Word gameModel.wordInput localUser.name "")
                                in
                                if isPlayer then
                                    ( { model | currentGame = Playing { gameModel | wordInput = "" } }, Api.addWord model.apiUrl game.id newWord )

                                else
                                    ( model, Cmd.none )

                        State.DeleteWord id ->
                            ( model, Api.deleteWord model.apiUrl game.id id )

                        QuitGame ->
                            -- TODO: remove the player from the list of players or set to offline
                            ( { model | currentGame = Initial { pinInput = "" }, errors = [] }, Cmd.none )

                        TimerTick _ ->
                            let
                                newTimerValue =
                                    gameModel.turnTimer - 1

                                cmd =
                                    if newTimerValue < 0 && gameModel.isOwner then
                                        let
                                            newGame =
                                                Game.Gameplay.endOfExplaining game
                                        in
                                        newGame
                                            |> Game.Game.gameEncoder
                                            |> changeGame

                                    else
                                        Cmd.none

                                normalisedTimer =
                                    if newTimerValue < 0 then
                                        0

                                    else
                                        newTimerValue
                            in
                            ( { model | currentGame = Playing { gameModel | turnTimer = normalisedTimer } }, cmd )

                        SwitchTimer ->
                            let
                                canSwitchTimer =
                                    Game.Gameplay.isLocalPlayersTurn game localUser

                                newGame =
                                    if canSwitchTimer then
                                        Game.Gameplay.switchTimer game gameModel.turnTimer

                                    else
                                        game
                            in
                            if canSwitchTimer then
                                ( model
                                , newGame
                                    |> Game.Game.gameEncoder
                                    |> changeGame
                                )

                            else
                                ( model, Cmd.none )

                        WordGuessed ->
                            let
                                newGameState =
                                    Game.Gameplay.guessWord gameModel.turnTimer game.state

                                newGame =
                                    { game | state = newGameState }
                            in
                            ( model
                            , newGame
                                |> Game.Game.gameEncoder
                                |> changeGame
                            )

                        GameChanged value ->
                            case Json.Decode.decodeValue gameDecoder value of
                                Ok decodedGame ->
                                    let
                                        newTimer =
                                            case decodedGame.state.turnTimer of
                                                Ticking ->
                                                    gameModel.turnTimer

                                                Game.Game.NotTicking timerValue ->
                                                    timerValue

                                                Game.Game.Restarted timerValue ->
                                                    timerValue

                                        isRoundEnd =
                                            Game.Gameplay.isRoundEnd decodedGame.state && decodedGame.state.round > 0
                                    in
                                    if game.id == decodedGame.id then
                                        ( { model | currentGame = Playing { gameModel | game = decodedGame, turnTimer = newTimer, isRoundEnd = isRoundEnd } }
                                        , if isRoundEnd then
                                            Delay.after 5000 Delay.Millisecond NextRound

                                          else
                                            Cmd.none
                                        )

                                    else
                                        ( model, Cmd.none )

                                Err _ ->
                                    ( model, Cmd.none )

                        _ ->
                            if gameModel.isOwner then
                                case msg of
                                    CopyInviteLink ->
                                        ( model, copyInviteLink (Json.Encode.string game.gameId) )

                                    AcceptUser user ->
                                        ( model, Api.acceptRequest model.apiUrl user game.id )

                                    StartGame ->
                                        let
                                            newGame =
                                                Game.Gameplay.startGame game
                                        in
                                        ( model
                                        , newGame
                                            |> Game.Game.gameEncoder
                                            |> changeGame
                                        )

                                    NextRound ->
                                        let
                                            newGame =
                                                Game.Gameplay.nextRound game
                                        in
                                        ( { model | currentGame = Playing { gameModel | isRoundEnd = False } }
                                        , newGame
                                            |> Game.Game.gameEncoder
                                            |> changeGame
                                        )

                                    _ ->
                                        Debugger.Update.update msg model

                            else
                                Debugger.Update.update msg model

                _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleHelpDialog ->
            ( { model | isHelpDialogOpen = not model.isHelpDialogOpen }, Cmd.none )

        ToggleDonateDialog ->
            ( { model | isDonateDialogOpen = not model.isDonateDialogOpen }, Cmd.none )

        UrlChanged url ->
            let
                newRoute =
                    Route.parseUrl url
            in
            case newRoute of
                Route.Join gameCode ->
                    ( { model | url = url, route = newRoute }, Api.findGame model.apiUrl gameCode )

                _ ->
                    ( { model | url = url, route = newRoute }, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.navKey (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        _ ->
            case model.currentGame of
                Initial gameModel ->
                    case msg of
                        EnterGame ->
                            ( { model | currentGame = LoadingGameToJoin { nameInput = "" } }, Api.findGame model.apiUrl gameModel.pinInput )

                        SetCreatingGameMode ->
                            ( { model | currentGame = CreatingGame { nameInput = "" } }, Nav.pushUrl model.navKey "create" )

                        UpdatePinInput input ->
                            ( { model | currentGame = Initial { pinInput = String.toUpper input } }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                LoadingGameToJoin gameModel ->
                    case msg of
                        UpdateNameInput input ->
                            ( { model | currentGame = LoadingGameToJoin { gameModel | nameInput = String.toUpper input } }, Cmd.none )

                        GameFound result ->
                            case result of
                                Ok game ->
                                    ( { model | currentGame = JoiningGame { game = game, nameInput = gameModel.nameInput } }, subscribeToGame (Json.Encode.string game.id) )

                                Err _ ->
                                    ( { model | errors = [ "Game not found" ] }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                CreatingGame gameModel ->
                    case msg of
                        UpdateNameInput input ->
                            ( { model | currentGame = CreatingGame { nameInput = String.toUpper input } }, Cmd.none )

                        AddGame ->
                            if String.isEmpty gameModel.nameInput then
                                ( model, Cmd.none )

                            else
                                let
                                    tempUser =
                                        User "" gameModel.nameInput

                                    newGame =
                                        Game.Game.createGameModel tempUser
                                in
                                ( model
                                , Api.addGame model.apiUrl gameModel.nameInput newGame
                                )

                        GameAdded result ->
                            case result of
                                Ok ( game, user ) ->
                                    ( { model | currentGame = Playing { game = game, isOwner = True, localUser = LocalPlayer user, wordInput = "", turnTimer = defaultTimer, isRoundEnd = False } }, subscribeToGame (Json.Encode.string game.id) )

                                Err _ ->
                                    ( model, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                JoiningGame gameModel ->
                    case msg of
                        UpdateNameInput input ->
                            ( { model | currentGame = JoiningGame { gameModel | nameInput = String.toUpper input } }, Cmd.none )

                        JoinedGame result ->
                            case result of
                                Ok joinedGameInfo ->
                                    let
                                        game =
                                            gameModel.game

                                        gameBelongsToUser =
                                            game.creator == joinedGameInfo.user.name

                                        userRole : Maybe UserRole
                                        userRole =
                                            case joinedGameInfo.status of
                                                "Game request added." ->
                                                    Just (LocalPlayer joinedGameInfo.user)

                                                "User is already in the game" ->
                                                    Just (LocalPlayer joinedGameInfo.user)

                                                "Game watcher added." ->
                                                    Just (LocalWatcher joinedGameInfo.user)

                                                _ ->
                                                    Nothing
                                    in
                                    case userRole of
                                        Just role ->
                                            ( { model | currentGame = Playing { localUser = role, isOwner = gameBelongsToUser, game = joinedGameInfo.game, wordInput = "", turnTimer = defaultTimer, isRoundEnd = False } }, Cmd.none )

                                        Nothing ->
                                            ( { model | errors = [ joinedGameInfo.status ] }, Cmd.none )

                                _ ->
                                    ( { model | errors = [ "Joining game error" ] }, Cmd.none )

                        JoinGame ->
                            ( model, Api.joinGame model.apiUrl gameModel.game.gameId gameModel.nameInput )

                        _ ->
                            ( model, Cmd.none )

                Playing _ ->
                    playingGameUpdate msg model



---- SUBSCRIPTOINS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        timerSub =
            case model.currentGame of
                Playing gameModel ->
                    case gameModel.game.state.turnTimer of
                        Game.Game.Ticking ->
                            Time.every 1000 TimerTick

                        _ ->
                            Sub.none

                _ ->
                    Sub.none
    in
    Sub.batch
        [ gameChanged GameChanged
        , timerSub
        ]



---- VIEW ----
---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
