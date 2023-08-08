# Users

# Lobby

    * Add loading state when creating/joining game/adding word or all buttons

    * When adding words input and button jump down once the word is added, test with chaning order of added words and input for the new one

    * Animate help button and add tips

# Game play

    * Explain when to click on let's play and start the game

    * Organize css

    * Save if visited before or use the above to auto open how to play on the first play

    * Finish game on disconnect?

# Code style

    * Add tests for Encoding/Decoding (especially for missing/empty states)

    * Rethink if creating a game should be on Elm side at all, atm empty game model is being created on Elm side and the "patched" in the cloud function, might make sense to have it all in the function but could introduce bugs when changing the model as the compiler wouldn't catch it
