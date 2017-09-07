import Game;

class GameRenderer
{
    static public function getSymbol(type:TileType)
    {
        return switch (type)
        {
            case EMPTY:
                " ";
            case GRASS:
                ".";
            case BUSH:
                "~";
            case TREE:
                "T";
            case HUT:
                "A";
            case HOUSE:
                "@";
            case MANSION:
                "M";
            case CASTLE:
                "§";
        }
    }

    static public function toAscii(board:Array<Array<Tile>>)
    {
        var out = "";

        for (i in board)
        {
            for (tile in i)
            {
                out += getSymbol(tile.type);
            }
            out += "\n";
        }

        return out;
    }

}
