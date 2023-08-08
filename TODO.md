# Users

# Lobby

    * Add loading state when creating/joining game/adding word or all buttons

    * Change help dialog font

    * Move donate and help button up at the top for desktop

    * Animate help button and add tips

    * Separate rules from advanced rules/tips for more competitive players

# Game play

    * Explain when to click on let's play and start the game

    * Add the same kind of count down before the first round

    * Organize css

    * Save if visited before or use the above to auto open how to play on the first play

    * Finish game on disconnect?

# Code style

    * Add tests for Encoding/Decoding (especially for missing/empty states)

    * Rethink if creating a game should be on Elm side at all, atm empty game model is being created on Elm side and the "patched" in the cloud function, might make sense to have it all in the function but could introduce bugs when changing the model as the compiler wouldn't catch it
