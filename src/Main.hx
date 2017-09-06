using Lambda;

class Main
{
    static public function main()
    {
        generateTrainingData();
    }

    static public function getAvailableMoves(g:Game)
    {
        var m = [];
        for (i in g.getBoard()) for (tile in i)
        {
            if (tile.type == EMPTY) m.push(tile);
        }

        return m;
    }

    static public function generateTrainingData()
    {
        var scores = [];
        for (i in 0...10000)
        {
            var g = new Game();
            // play until no moves are available
            var moves = [];
            while ((moves = getAvailableMoves(g)).length > 0)
            {
                var moveToPlay = moves[Std.random(moves.length)];
                g.play({x: moveToPlay.x, y: moveToPlay.y}, GRASS);
            }

            var score = GameScore.scoreBoard(g.getBoard());
            scores.push(score);
            //trace(GameRenderer.toAscii(g.getBoard()));
        }

        var total = scores.fold(function(n, t) return t + n, 0);
        trace("Mean: "+(total/scores.length));

        var min = scores.fold(function(n, t) return if (n < t) n else t, 9999);
        var max = scores.fold(function(n, t) return if (n > t) n else t, 0);
        trace("Min: "+min);
        trace("Max: "+max);
    }

    #if js
    static public function manualPlay()
    {
        var g = new Game();
        turn(g);
    }

    static public function turn(g:Game)
    {
        var out = GameRenderer.toAscii(g.getBoard());
        trace(out);

        var rl = js.node.Readline.createInterface({
            input: js.Node.process.stdin,
            output: js.Node.process.stdout,
        });

        rl.question("Where to play? ", function(answer)
        {
            answer = answer.substr(0, 2);
            var x = Std.parseInt(answer.substr(0, 1));
            var y = Std.parseInt(answer.substr(1, 1));

            var result = g.play({x: x, y: y}, GRASS);
            if (!result)
            {
                trace("INVALID MOVE");
            }

            rl.close();
            turn(g);
        });
    }
    #end
}
