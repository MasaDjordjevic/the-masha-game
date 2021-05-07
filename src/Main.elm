port module Main exposing (..)

import Browser
import Debugger.Update
import Delay
import Dict 
import Game.Game exposing (..)
import Game.Gameplay
import Game.Participants
import Game.Words exposing (Word)
import Json.Decode
import Json.Encode
import State exposing (GameModel(..), Msg(..), Model, Flags)
import Time
import User exposing (..)
import Views.View exposing (view)
import Game.Words
import Api 
import Constants exposing (defaultTimer)
import State exposing (GameModel(..))
import State 

devApiUrl: String
devApiUrl = "http://localhost:5001/themashagame-990a8/us-central1"


--- PORTS ----


port subscribeToGame : Json.Encode.Value -> Cmd msg


port gameChanged : (Json.Decode.Value -> msg) -> Sub msg


port changeGame : Json.Encode.Value -> Cmd msg



---- MODEL ----


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { currentGame = Initial { pinInput = "" }
      , environment = flags.environment
      , apiUrl = if flags.environment == "development" then devApiUrl else ""
      , errors = []
      , isHelpDialogOpen = False
      }
    , Cmd.none
    )


playingGameUpdate : Msg -> Model -> ( Model, Cmd Msg )
playingGameUpdate msg model =
    case ( model.currentGame ) of
        Playing gameModel ->
            let 
                game = gameModel.game
                localUser = gameModel.localUser
            in                      
                case msg of
                    UpdateWordInput input ->
                        ( { model | currentGame = Playing { gameModel | wordInput = String.toUpper input }}, Cmd.none )
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
                                ({ model | currentGame = Playing { gameModel | wordInput = "" }}, Api.addWord model.apiUrl game.id newWord)

                            else
                                ( model, Cmd.none )

            

                    State.DeleteWord id ->
                        ( model, Api.deleteWord model.apiUrl game.id id )

                    QuitGame ->
                        -- TODO: remove the player from the list of players or set to offline
                        ({model |  currentGame = Initial {pinInput = ""}, errors = [] }, Cmd.none )

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
                        ( { model | currentGame = Playing {gameModel | turnTimer = normalisedTimer} }, cmd )

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
                                    ( { model | currentGame = Playing {gameModel | game = decodedGame, turnTimer = newTimer, isRoundEnd = isRoundEnd }}

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
                                AcceptUser user ->
                                    (model, Api.acceptRequest model.apiUrl user game.id)
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
                                        ( { model | currentGame =  Playing { gameModel | isRoundEnd = False } }
                                        , newGame
                                            |> Game.Game.gameEncoder
                                            |> changeGame
                                        )
                                _ -> 
                                    Debugger.Update.update msg model
                            else 
                                Debugger.Update.update msg model
                        

        ( _ ) ->
            ( model, Cmd.none )



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleHelpDialog ->
                    ( { model | isHelpDialogOpen = not model.isHelpDialogOpen }, Cmd.none )
        _ ->
            case model.currentGame of 
                Initial gameModel ->
                    case msg of
                        EnterGame ->
                            ( model, Api.findGame model.apiUrl gameModel.pinInput )
                        SetCreatingGameMode ->
                            ( { model | currentGame = CreatingGame {nameInput = ""} }, Cmd.none )
                        UpdatePinInput input ->
                            ( { model | currentGame = Initial { pinInput = String.toUpper input} }, Cmd.none )
                        GameFound result-> 
                            case result of 
                                Ok game ->
                                    ( { model | currentGame = JoiningGame {game = game, nameInput = "" }}, subscribeToGame (Json.Encode.string game.id) )
                                Err _ -> 
                                    ( { model | errors = [ "Game not found" ] }, Cmd.none )
                        _ -> 
                            (model, Cmd.none)

                CreatingGame gameModel ->
                    case msg of
                        UpdateNameInput input ->
                            ( { model | currentGame = CreatingGame {nameInput = String.toUpper input} }, Cmd.none )
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
                        GameAdded result-> 
                            case result of 
                                Ok (game, user) ->                
                                    ( { model | currentGame = Playing {game = game, isOwner = True, localUser =  user, wordInput = "", turnTimer = defaultTimer, isRoundEnd = False }},  subscribeToGame (Json.Encode.string game.id) )
                                Err _ -> 
                                    ( model, Cmd.none )
                        _ -> 
                            (model, Cmd.none)

                JoiningGame gameModel ->
                    case msg of
                        UpdateNameInput input ->
                            ( { model | currentGame = JoiningGame {gameModel | nameInput = String.toUpper input} }, Cmd.none )
                        JoinedGame result -> 
                            case result of
                                Ok (status, user) ->
                                    let
                                        game = gameModel.game
                                        gameBelongsToUser = game.creator == user.name
        
                                        newGame = 
                                            case status of
                                                "Game request added." -> 
                                                    let
                                                        newParticipants = Game.Participants.addJoinRequest user game.participants
                                                    in
                                                        ({game | participants = newParticipants})
                                                    
                                                _ -> 
                                                    game
                                        
                                    in
                                    ({model | currentGame = Playing { localUser =  user,  isOwner = gameBelongsToUser, game = newGame,  wordInput = "", turnTimer = defaultTimer, isRoundEnd = False}}, Cmd.none)
                                _ ->
                                    ( { model | errors = [ "Joining game error" ] }, Cmd.none )
                        JoinGame ->
                            (model, Api.joinGame model.apiUrl  gameModel.game.gameId gameModel.nameInput)

                        _ ->
                            (model, Cmd.none)


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
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
