using Lambda;
using Std;

typedef Tile =
{
    var type: TileType;
    var x: Int;
    var y: Int;
    var turn: Int;
}

typedef Position =
{
    var x:Int;
    var y:Int;
}

enum TileType
{
    EMPTY;
    GRASS;
    BUSH;
    TREE;
    HUT;
    HOUSE;
}

class Game
{
    static inline private var BOARD_SIZE = 6;

    var board:Array<Array<Tile>>;
    var currentTurn:Int;

    static public function transformInto(type:TileType)
    {
        return switch (type)
        {
            case EMPTY, HOUSE:
                EMPTY;
            case GRASS:
                BUSH;
            case BUSH:
                TREE;
            case TREE:
                HUT;
            case HUT:
                HOUSE;
        }
    }

    public function getBoard()
    {
        return board;
    }

    public function new()
    {
        currentTurn = 0;
        board = [];
        for (i in 0...BOARD_SIZE)
        {
            var line = [];
            for (y in 0...BOARD_SIZE)
            {
                line.push({
                    type: EMPTY,
                    x: y,
                    y: i,
                    turn: 0
                });
            }
            board.push(line);
        }
    }

    public function getTileAt(pos:Position)
    {
        if (pos.x < 0 || pos.y < 0 || pos.y >= board.length || pos.x >= board[pos.y].length)
            return null;

        return board[pos.y][pos.x];
    }

    public function play(pos:Position, type:TileType):Bool
    {
        //trace("Playing "+type+" at "+pos.x+";"+pos.y);
        var tile = getTileAt(pos);
        if (tile.type != EMPTY)
            return false;

        tile.type = type;
        tile.turn = currentTurn;

        currentTurn++;

        resolve();
        return true;
    }

    private function getNeigh(tile:Tile, exclude:Array<Tile>)
    {
        var out = [];
        var dir = [[0, -1], [0, 1], [1, 0], [-1, 0]];
        for (i in dir)
        {
            var c = getTileAt({x: tile.x + i[0], y: tile.y + i[1]});
            if (c != null && c.type == tile.type && !exclude.has(c))
                out.push(c);
        }

        return out;
    }

    private function makeGroup(grouped:Array<Tile>, tile:Tile)
    {
        var neigh = getNeigh(tile, grouped);
        for (i in neigh)
        {
            grouped.push(i);
        }
        for (i in neigh)
        {
            makeGroup(grouped, i);
        }
    }

    private function mergeGroup(group:Array<Tile>)
    {
        // Look for older tile
        var younger:Tile = null;
        for (i in group)
        {
            if (younger == null || i.turn > younger.turn)
                younger = i;
        }

        // Remove group and transform tile at older pos
        for (i in group)
        {
            if (i != younger)
                i.type = EMPTY;
        }
        younger.type = transformInto(younger.type);

        resolve();
    }

    private function resolve()
    {
        // Let's make groups
        var grouped = [];
        for (i in board) for (tile in i)
        {
            if (tile.type != EMPTY)
            {
                if (!grouped.has(tile))
                {
                    var group = [tile];
                    makeGroup(group, tile);
                    for (t in group)
                    {
                        grouped.push(t);
                    }
                    if (group.length >= 3)
                    {
                        //trace('Group to merge found (${group.length} ${tile.type})');
                        mergeGroup(group);
                        return;
                    }
                }
            }
        }
    }
}
