module Game.Gameplay exposing (..)

import Game.Game exposing (Game, GameState, TurnTimer(..))
import Game.Status
import Game.Teams
import Game.Words
import User


isRoundEnd : GameState -> Bool
isRoundEnd gameState =
    case gameState.words.current of
        Just _ ->
            Basics.False

        Nothing ->
            List.isEmpty gameState.words.next


startGame : Game -> Game
startGame game =
    let
        oldState =
            game.state

        newState =
            { oldState | round = 0 }
    in
    { game | status = Game.Status.Running, state = newState }


isLocalPlayersTurn : Game -> User.User -> Bool
isLocalPlayersTurn game user =
    let
        teamOnTurn =
            game.state.teams.current

        isLocPlayersTurn =
            case teamOnTurn of
                Just currentTeam ->
                    List.member user currentTeam.players

                Nothing ->
                    False
    in
    isLocPlayersTurn


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


nextRound : Game -> Game
nextRound game =
    let
        newRound =
            game.state.round + 1

        oldState =
            game.state

        newState =
            case newRound of
                0 ->
                    game.state

                1 ->
                    let
                        newTeams =
                            Game.Teams.createTeams game.participants.players

                        -- shuffle words
                        newWords =
                            Game.Words.failCurrentWord game.state.words
                    in
                    { oldState | teams = newTeams, words = newWords }

                _ ->
                    let
                        newWords =
                            Game.Words.restartWords game.state.words
                    in
                    { oldState | words = newWords }

        newStatus =
            if newRound == 4 then
                Game.Status.Finished

            else
                game.status
    in
    { game | state = { newState | round = newRound }, status = newStatus }


endOfExplaining : Game -> Game
endOfExplaining game =
    let
        newTeams =
            Game.Teams.advanceCurrentTeam game.state.teams

        newWords =
            Game.Words.failCurrentWord game.state.words

        oldState =
            game.state

        newState =
            { oldState | teams = newTeams, words = newWords, turnTimer = Game.Game.Restarted game.defaultTimer }
    in
    { game | state = newState }


startExplaining : GameState -> Int -> GameState
startExplaining state localTimerValue =
    let
        newWords =
            case state.words.current of
                Just _ ->
                    state.words

                Maybe.Nothing ->
                    -- succeedCurrentWord in this case will take a word from next to current
                    Game.Words.succeedCurrentWord state.words

        newTurnTimer =
            case state.turnTimer of
                Game.Game.NotTicking _ ->
                    Game.Game.Ticking

                Game.Game.Ticking ->
                    Game.Game.NotTicking localTimerValue

                Game.Game.Restarted _ ->
                    Game.Game.Ticking
    in
    { state | words = newWords, turnTimer = newTurnTimer }


switchTimer : Game -> Int -> Game
switchTimer game localTimerValue =
    let
        newState =
            startExplaining game.state localTimerValue
    in
    { game | state = newState }


pauseTimerIfAllWordsGuessed : GameState -> Int -> TurnTimer
pauseTimerIfAllWordsGuessed gameState localTimerValue =
    case ( gameState.turnTimer, isRoundEnd gameState ) of
        ( Ticking, True ) ->
            Game.Game.NotTicking localTimerValue

        ( _, _ ) ->
            gameState.turnTimer


guessWord : Int -> GameState -> GameState
guessWord localTimerValue gameState =
    let
        newWords =
            Game.Words.succeedCurrentWord gameState.words

        newTeams =
            Game.Teams.increaseCurrentTeamsScore gameState.teams

        newState =
            { gameState | words = newWords, teams = newTeams }

        newGameTimer =
            pauseTimerIfAllWordsGuessed newState localTimerValue
    in
    { newState | turnTimer = newGameTimer }
