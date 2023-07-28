type Word = {
  word: string;
  player: string;
  id: string;
};

type User = {
  id: string;
  name: string;
};

type JoinRequest = {
  id: string;
  name: string;
};
type Game = {
  id: string;
  participants: {
    joinRequests: { [key: string]: JoinRequest };
    players: { [key: string]: User };
  };
  state: {
    round: number;
  };
};
