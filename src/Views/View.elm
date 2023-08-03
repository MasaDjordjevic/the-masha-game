module Views.View exposing (view)

import Browser
import Debugger.Debugger exposing (debugger)
import Game.Status
import Html exposing (div, text)
import Html.Attributes exposing (..)
import State exposing (..)
import Views.AddingWords exposing (addingWordsView)
import Views.Donate exposing (donateView)
import Views.EndOfRound exposing (endOfRoundView)
import Views.FinishedGame exposing (finishedGameView)
import Views.Header exposing (headerView)
import Views.Help exposing (helpView)
import Views.Lobby exposing (lobbyView)
import Views.NameInput exposing (nameInputView)
import Views.Playing.Playing exposing (playingView)
import Views.Start exposing (startView)


view : Model -> Browser.Document Msg
view model =
    { title = "The Masha Game"
    , body =
        [ let
            currView =
                case model.currentGame of
                    Playing gameModel ->
                        case gameModel.game.status of
                            Game.Status.Open ->
                                lobbyView gameModel

                            Game.Status.Running ->
                                if gameModel.isRoundEnd then
                                    endOfRoundView gameModel.game

                                else
                                    case gameModel.game.state.round of
                                        0 ->
                                            addingWordsView gameModel

                                        _ ->
                                            playingView gameModel

                            Game.Status.Finished ->
                                finishedGameView gameModel.game

                    CreatingGame gameModel ->
                        nameInputView gameModel.nameInput AddGame

                    LoadingGameToJoin gameModel ->
                        nameInputView gameModel.nameInput JoinGame

                    JoiningGame gameModel ->
                        nameInputView gameModel.nameInput JoinGame

                    Initial gameModel ->
                        startView gameModel model.errors

            showHeader =
                case model.currentGame of
                    Initial _ ->
                        Basics.False

                    _ ->
                        Basics.True
          in
          div []
            [ div [ class "page-wrapper" ]
                [ div [ class "page-container" ]
                    [ if showHeader then
                        headerView

                      else
                        text ""
                    , currView
                    ]
                , donateView model
                , helpView model
                ]
            , debugger model
            ]
        ]
    }
