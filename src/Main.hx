using Lambda;

import haxe.ds.StringMap;
import RegTree;

class Main
{
    static public function main()
    {
        var trainingData = generateTrainingData(10000);

        trace('Generated ${trainingData.length} samples');

        var rt = new RegTree();
        rt.train(trainingData);
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

    static public function generateTrainingData(numPlays:Int):Array<Sample>
    {
        var samples:StringMap<Sample> = new StringMap();
        for (i in 0...numPlays)
        {
            var g = new Game();
            // play until no moves are available
            var moves = [];
            var movesPlayed = [];
            while ((moves = getAvailableMoves(g)).length > 0)
            {
                var moveToPlay = moves[Std.random(moves.length)];

                movesPlayed.push(g.getAllNeigh(moveToPlay));

                g.play({x: moveToPlay.x, y: moveToPlay.y}, GRASS);
            }

            var score = GameScore.scoreBoard(g.getBoard());

            for (p in movesPlayed)
            {
                var moveStr = p.join(",");
                var move = samples.get(moveStr);
                if (move != null)
                {
                    move.score = ((move.score * move.n) + score) / (move.n + 1);
                    move.n++;
                }
                else
                {
                    samples.set(moveStr, {variables: p, score: score, n: 1});
                }
            }
            //trace(GameRenderer.toAscii(g.getBoard()));

            if (i % (numPlays / 20) == 0)
            {
                trace('$i / $numPlays');
            }
        }

        return samples.array();
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
