import Game;

class GameScore
{
    static inline private function getScore(type:TileType)
    {
        return switch (type)
        {
            case EMPTY: 0;
            case GRASS: 1;
            case BUSH: 2;
            case TREE: 4;
            case HUT: 8;
            case HOUSE: 16;
            case MANSION: 32;
            case CASTLE: 64;
        }
    }

    static public function scoreBoard(board:Array<Array<Tile>>)
    {
        var out = 0;

        for (i in board)
        {
            for (tile in i)
            {
                out += getScore(tile.type);
            }
        }

        return out;
    }

}
