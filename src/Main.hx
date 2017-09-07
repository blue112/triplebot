using Lambda;

import RegTree;

class Main
{
    static public function main()
    {
        var trainingData = haxe.Timer.measure(generateTrainingData.bind(5000));

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
        var samples = [];
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
                samples.push({variables: p, score: score});
            }
            //trace(GameRenderer.toAscii(g.getBoard()));
        }

        return samples;
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
