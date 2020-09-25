import "./main.css";
import { Elm } from "./Main.elm";
import * as serviceWorker from "./serviceWorker";

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
// firebase.analytics();

const USERS_PATH = "users";
const GAMES_PATH = "games";

const users = {
  register: (userName) => database.ref(USERS_PATH).push({ name: userName }),

  ref: database.ref(USERS_PATH),
};

const words = {
  addWord: (gameId, word) =>
    database
      .ref(`${GAMES_PATH}/${gameId}/state/words/next/${word.id}`)
      .set(word),
  deleteWord: (gameId, wordId) =>
    database.ref(`${GAMES_PATH}/${gameId}/state/words/next/${wordId}`).remove(),
};

const games = {
  open: (game) => database.ref(GAMES_PATH).push(game),
  requestToJoinGame: (gameId, user) =>
    database
      .ref(`${GAMES_PATH}/${gameId}/participants/joinRequests/${user.id}`)
      .set(user),
  acceptRequest: (gameId, user) => {
    database
      .ref(`${GAMES_PATH}/${gameId}/participants/joinRequests/${user.id}`)
      .remove();

    database.ref(`${GAMES_PATH}/${gameId}/participants/players`).push(user);
  },
  update: (game) => database.ref(`${GAMES_PATH}/${game.id}`).set(game),
  ref: database.ref(GAMES_PATH),
};

const app = Elm.Main.init({
  node: document.getElementById("root"),
  flags: { environment: process.env.NODE_ENV },
});

const registerLocalUser = (userName) => {
  console.log("registering user ", userName);

  return users.ref
    .orderByChild("name")
    .equalTo(userName)
    .once("value")
    .then((res) => {
      console.log("Found: ", res.val());
      if (res.val()) {
        const key = Object.keys(res.val())[0];
        if (res.val()[key].name === userName) {
          console.log("user found", userName);
          return {
            id: key,
            name: userName,
          };
        }
      } else {
        users.register(userName).then((res) => {
          console.log("user registered ", userName);
          return {
            id: key,
            name: userName,
          };
        });
      }
    });
};

games.ref
  // .orderByChild("status")
  // .equalTo("open")
  .on("child_added", (data) => {
    const game = { ...data.val(), id: data.key };
    console.log("new game", game);

    app.ports.openGameAdded.send(game);
  });

app.ports.addGame.subscribe((game) => {
  const userName = game.creator;
  console.log("adding user: ", userName);
  const localUser = registerLocalUser(userName);
  localUser.then((user) => {
    console.log("user", user);
    app.ports.localUserRegistered.send(user);
    console.log("adding game: ", game);
    const newGame = {
      ...game,
      participants: { ...game.participants, players: { [user.id]: user } },
    };
    console.log("but changed to:", newGame);
    games.open(newGame);
  });
});

app.ports.requestToJoinGame.subscribe(({ gameId, user }) => {
  const userName = user.name;
  console.log("adding user: ", userName);
  const localUser = registerLocalUser(userName);
  localUser.then((user) => {
    app.ports.localUserRegistered.send(user);

    console.log("request ", user.name, " to ", gameId);
    return games.requestToJoinGame(gameId, user);
  });
});

app.ports.acceptRequest.subscribe(({ gameId, user }) => {
  console.log("accepting ", user.name);
  return games.acceptRequest(gameId, user);
});

games.ref.on("child_changed", (data) => {
  const game = { ...data.val(), id: data.key };
  console.log("new game", game);
  app.ports.gameChanged.send(game);
});

app.ports.changeGame.subscribe((game) => {
  console.log("updating game to", game);
  games.update(game);
});

app.ports.addWord.subscribe(({ gameId, word }) => {
  words.addWord(gameId, word);
});

app.ports.deleteWord.subscribe(({ gameId, wordId }) => {
  console.log("deleting word: ", gameId, wordId);
  words.deleteWord(gameId, wordId);
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
