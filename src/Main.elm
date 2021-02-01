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
import Maybe
import State exposing (..)
import Time
import User exposing (..)
import Views.View exposing (view)
import Game.Words
import Api 

devApiUrl: String
devApiUrl = "http://localhost:5001/themashagame-990a8/us-central1"


--- PORTS ----


port subscribeToGame : Json.Encode.Value -> Cmd msg


port gameChanged : (Json.Decode.Value -> msg) -> Sub msg


port changeGame : Json.Encode.Value -> Cmd msg



---- MODEL ----


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { localUser = Maybe.Nothing
      , nameInput = ""
      , game = Maybe.Nothing
      , wordInput = ""
      , isOwner = False -- TODO: this should not be separate from the game or should be Maybe
      , turnTimer = 60
      , environment = flags.environment
      , apiUrl = if flags.environment == "development" then devApiUrl else ""
      , playMode = Maybe.Nothing
      , pinInput = ""
      , errors = []
      , isRoundEnd = False
      , isHelpDialogOpen = False
      }
    , Cmd.none
    )


playingGameUpdate : Msg -> Model -> ( Model, Cmd Msg )
playingGameUpdate msg model =
    case ( model.game, model.localUser ) of
        ( Just game, Just localUser ) ->
            case msg of
                AcceptUser user ->
                    if model.isOwner then
                        (model, Api.acceptRequest model.apiUrl user game.id)

                    else
                        ( model, Cmd.none )

                
                StartGame ->
                    if model.isOwner then
                        let
                            newGame =
                                Game.Gameplay.startGame game
                        in
                        ( model
                        , newGame
                            |> Game.Game.gameEncoder
                            |> changeGame
                        )

                    else
                        ( model, Cmd.none )

                State.AddWord ->
                    if String.isEmpty model.wordInput then
                        ( model, Cmd.none )

                    else
                        let
                            isPlayer =
                                Dict.member localUser.id game.participants.players

                            newWord =
                                Game.Words.wordWithKey 0 (Word model.wordInput localUser.name "")
                        in
                        if isPlayer then
                            (model, Api.addWord model.apiUrl game.id newWord)

                        else
                            ( model, Cmd.none )

                NextRound ->
                    if model.isOwner then
                        let
                            newGame =
                                Game.Gameplay.nextRound game
                        in
                        ( { model | isRoundEnd = False }
                        , newGame
                            |> Game.Game.gameEncoder
                            |> changeGame
                        )

                    else
                        ( model, Cmd.none )

                State.DeleteWord id ->
                    ( model, Api.deleteWord model.apiUrl game.id id )

                QuitGame ->
                    -- TODO: remove the player from the list of players or set to offline
                    ( { model | game = Maybe.Nothing }, Cmd.none )

                TimerTick _ ->
                    let
                        newTimerValue =
                            model.turnTimer - 1

                        cmd =
                            if newTimerValue < 0 && model.isOwner then
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
                    ( { model | turnTimer = normalisedTimer }, cmd )

                SwitchTimer ->
                    let
                        canSwitchTimer =
                            Game.Gameplay.isLocalPlayersTurn game localUser

                        newGame =
                            if canSwitchTimer then
                                Game.Gameplay.switchTimer game model.turnTimer

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
                            Game.Gameplay.guessWord model.turnTimer game.state

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
                                            model.turnTimer

                                        Game.Game.NotTicking timerValue ->
                                            timerValue

                                        Game.Game.Restarted timerValue ->
                                            timerValue

                                isRoundEnd =
                                    Game.Gameplay.isRoundEnd decodedGame.state && decodedGame.state.round > 0
                            in
                            if game.id == decodedGame.id then
                                ( { model | game = Just decodedGame, turnTimer = newTimer, isRoundEnd = isRoundEnd }
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
                    Debugger.Update.update msg model

        ( _, _ ) ->
            ( model, Cmd.none )



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetPlayMode mode ->
            ( { model | playMode = Just mode }, Cmd.none )

        UpdateNameInput input ->
            ( { model | nameInput = String.toUpper input }, Cmd.none )

        UpdateWordInput input ->
            ( { model | wordInput = String.toUpper input }, Cmd.none )

        UpdatePinInput input ->
            ( { model | pinInput = String.toUpper input }, Cmd.none )

       

        AddGame ->
            if String.isEmpty model.nameInput then
                ( model, Cmd.none )

            else
                let
                    tempUser =
                        User "" model.nameInput

                    newGame =
                        Game.Game.createGameModel tempUser
                in
                ( model
                , Api.addGame model.apiUrl model.nameInput newGame 
                    
                )

        GameAdded result-> 
            case result of 
                Ok (game, user) ->                
                    ( { model | game = Just game, isOwner = True, playMode = Just State.PlayingGame, localUser = Just user },  subscribeToGame (Json.Encode.string game.id) )
                Err _ -> 
                     ( model, Cmd.none )


        EnterGame ->
            ( model, Api.findGame model.apiUrl model.pinInput )

        GameFound result-> 
            case result of 
                Ok game ->
                    ( { model | game = Just game, playMode = Just State.JoiningGame }, subscribeToGame (Json.Encode.string game.id) )
                Err _ -> 
                    ( { model | errors = [ "Game not found" ] }, Cmd.none )

        JoinedGame result -> 
            case result of
               Ok (status, user) ->
                    let
                        gameBelongsToUser =
                            case model.game of
                                Just game ->
                                    game.creator == user.name

                                Nothing ->
                                    False
                        newGame = 
                            case status of
                                "Game request added." -> Maybe.map (\game -> 
                                    let
                                        newParticipants = Game.Participants.addJoinRequest user game.participants
                                    in
                                        ({game | participants = newParticipants})
                                    ) model.game
                                _ -> 
                                    model.game
                           
                    in
                    ({model | localUser = Just user, playMode = Just State.PlayingGame, isOwner = gameBelongsToUser, game = newGame}, Cmd.none)
               Err _ ->
                ( { model | errors = [ "Joining game error" ] }, Cmd.none )
        JoinGame ->
            case model.game of
                Just game ->
                    (model, Api.joinGame model.apiUrl game.gameId model.nameInput)
                Nothing ->
                    ( model, Cmd.none )
           

        ToggleHelpDialog ->
            ( { model | isHelpDialogOpen = not model.isHelpDialogOpen }, Cmd.none )

        _ ->
            playingGameUpdate msg model



---- SUBSCRIPTOINS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        timerSub =
            case model.game of
                Just game ->
                    case game.state.turnTimer of
                        Game.Game.Ticking ->
                            Time.every 1000 TimerTick

                        _ ->
                            Sub.none

                Nothing ->
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
