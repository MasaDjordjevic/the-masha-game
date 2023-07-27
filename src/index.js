import "./main.css";
import { Elm } from "./Main.elm";
import * as serviceWorker from "./serviceWorker";
import NoSleep from "nosleep.js";

var noSleep = new NoSleep();

function enableNoSleep() {
  noSleep.enable();
  document.removeEventListener("touchstart", enableNoSleep, false);
}

// Enable wake lock.
// (must be wrapped in a user input event handler e.g. a mouse or touch handler)
document.addEventListener("touchstart", enableNoSleep, false);

// Your web app's Firebase configuration
var firebaseConfig = {
  apiKey: "AIzaSyA_Hv4Deh_usUCTACNLESTxpyM4QHWfv58",
  authDomain: "themashagame-990a8.firebaseapp.com",
  databaseURL: "https://themashagame-990a8.firebaseio.com",
  projectId: "themashagame-990a8",
  storageBucket: "themashagame-990a8.appspot.com",
  messagingSenderId: "616742583607",
  appId: "1:616742583607:web:cae493ca4fc3a05e98eeb2",
  measurementId: "G-5NL1EL32WM",
};
// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const database = firebase.database();

const app = Elm.Main.init({
  node: document.getElementById("root"),
  flags: {
    environment: process.env.NODE_ENV,
  },
});

const GAMES_PATH = "games";

app.ports.subscribeToGame.subscribe((id) => {
  console.log("subscribing to game", id);
  database.ref(`${GAMES_PATH}/${id}`).on("child_changed", () => {
    database
      .ref(`${GAMES_PATH}/${id}`)
      .once("value")
      .then((data) => {
        const newGame = { ...data.val(), id: data.key };
        console.log("new game data", newGame);
        app.ports.gameChanged.send(newGame);
      });
  });
});

app.ports.changeGame.subscribe((game) => {
  console.log("updating game to", game);
  database.ref(`${GAMES_PATH}/${game.id}`).set(game);
});

app.ports.copyInviteLink.subscribe((gameId) => {
  console.log("copy to clipboard", gameId);
  navigator.clipboard.writeText(`${window.location.origin}/join/${gameId}`);
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
