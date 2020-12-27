import * as functions from "firebase-functions";
import { games, users } from "./db";

type NotFoundUser = { found: boolean };
type FoundUser = { found: boolean; id: string; name: string };
type FindUser = FoundUser | NotFoundUser;
const isFound = (user: FindUser): user is FoundUser =>
  user.found && "id" in user;

const findUser = (username: string): Promise<FindUser> =>
  users.get(username).then((res) => {
    const val = res.val();
    if (res.key && val?.name) {
      return {
        found: true,
        id: res.key,
        name: val?.name,
      };
    } else {
      return {
        found: false,
      };
    }
  });

const findOrAddUser = async (username: string) => {
  const user = await findUser(username);
  if (isFound(user)) {
    return {
      id: user.id,
      name: user.name,
    };
  } else {
    const addedUser = await users.add(username);
    if (addedUser.id) {
      return addedUser;
    } else {
      throw new Error("Registering user failed");
    }
  }
};

export const createGame = async (username: string, game: any) => {
  const addedUser = await findOrAddUser(username);
  if (!addedUser.id) {
    return;
  }
  functions.logger.info(
    `User with username: ${addedUser.name} succesfully found/added: ${addedUser.id}.`
  );
  const numGamesWithSameCreator = await games.getByCreator(username);
  const gameIdSuffix = numGamesWithSameCreator ? +numGamesWithSameCreator : "";
  const newGame = {
    ...game,
    gameId: game.creator + gameIdSuffix,
    participants: {
      ...game.participants,
      players: { [addedUser.id]: addedUser },
    },
  };
  functions.logger.info(`New game: ${newGame}.`);
  return games.add(newGame).then((addedGame) => ({
    game: addedGame,
    user: addedUser,
  }));
};

export const createJoinRequest = async (
  username: string,
  gameId: string
): Promise<User> => {
  const addedUser = await findOrAddUser(username);

  return games.requestToJoinGame(gameId, addedUser).then(() => {
    return addedUser;
  });
};

export const findGameByGameId = async (gameId: string) => {
  return games.getByGameId(gameId).then((res) => {
    return Object.values(res.val())[0];
    const key = res.key;
    const game = res.val();
    if (key && game) {
      const newGame = {
        ...game,
        id: key,
      };
      console.log("found game", newGame);
      return newGame;
    } else {
      return null;
    }
  });
};
