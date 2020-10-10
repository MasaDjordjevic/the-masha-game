module Game.Gameplay exposing (..)

import Game.Game exposing (Game, GameState, TurnTimer(..))
import Game.Status
import Game.Teams
import Game.Words
import User


isRoundEnd : Game -> Bool
isRoundEnd game =
    case game.state.words.current of
        Just _ ->
            Basics.False

        Nothing ->
            List.isEmpty game.state.words.next


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
            game.round + 1

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

        newGame =
            { game | state = newState, status = newStatus }
    in
    { newGame | round = newRound }


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
            { oldState | teams = newTeams, words = newWords }
    in
    { game | state = newState, turnTimer = Game.Game.Restarted game.defaultTimer }


startExplaining : GameState -> TurnTimer -> GameState
startExplaining state turnTimer =
    let
        newWords =
            case turnTimer of
                Restarted _ ->
                    -- succeedCurrentWord in this case will take a word from next to current
                    Game.Words.succeedCurrentWord state.words

                _ ->
                    state.words
    in
    { state | words = newWords }


switchTimer : Game -> Int -> Game
switchTimer game localTimerValue =
    let
        newState =
            startExplaining game.state game.turnTimer

        newTurnTimer =
            case game.turnTimer of
                Game.Game.NotTicking _ ->
                    Game.Game.Ticking

                Game.Game.Ticking ->
                    Game.Game.NotTicking localTimerValue

                Game.Game.Restarted _ ->
                    Game.Game.Ticking
    in
    { game | turnTimer = newTurnTimer, state = newState }


pauseTimerIfAllWordsGuessed : Game -> Int -> TurnTimer
pauseTimerIfAllWordsGuessed game localTimerValue =
    case ( game.turnTimer, isRoundEnd game ) of
        ( Ticking, True ) ->
            Game.Game.NotTicking localTimerValue

        ( _, _ ) ->
            game.turnTimer


guessWord : Int -> Game -> Game
guessWord localTimerValue game =
    let
        newWords =
            Game.Words.succeedCurrentWord game.state.words

        newTeams =
            Game.Teams.increaseCurrentTeamsScore game.state.teams

        oldState =
            game.state

        newState =
            { oldState | words = newWords, teams = newTeams }

        gameWithNewState =
            { game | state = newState }

        newGameTimer =
            pauseTimerIfAllWordsGuessed gameWithNewState localTimerValue
    in
    { gameWithNewState | turnTimer = newGameTimer }
