using Lambda;

typedef Condition =
{
    var variable_n:Int;
    var variable_values:Array<String>;
}

typedef Path =
{
    var condition: Condition;
    var next_node: Node;
}

typedef Node =
{
    @:optional var end_value: Int;
    @:optional var left_path: Path;
    @:optional var right_path: Path;
}

typedef Sample =
{
    var variables: Array<Dynamic>;
    var score:Float;
    var n:Int;
}

class RegTree
{
    var main_node:Node;

    public function new()
    {
        main_node = {
            end_value: 0
        };
    }

    public function train(data:Array<Sample>)
    {
        // Split data
        var growData = data.slice(0, Std.int(data.length / 2));
        var pruneData = data.slice(Std.int(data.length / 2));

        //Grow
        split(growData, main_node);

        trace("Before pruning: "+getDepth(main_node)+" depth");
        //trace(haxe.Serializer.run(main_node));

        prune(pruneData, main_node);
        trace("After pruning: "+getDepth(main_node)+" depth");
    }

    private function prune(pruneData:Array<Sample>, node:Node)
    {
        var currentImpurity = getImpurity(pruneData);

        if (node.left_path == null || node.right_path == null)
            return false;

        var left_data = filterData(pruneData, node.left_path.condition, true);
        var right_data = filterData(pruneData, node.right_path.condition, false);
        var child_impurity = getImpurity(left_data) + getImpurity(right_data);

        if (child_impurity >= currentImpurity * 0.99)
        {
            // Prune myself
            node.left_path = null;
            node.right_path = null;
            return true;
        }
        else
        {
            prune(left_data, node.left_path.next_node);
            prune(right_data, node.right_path.next_node);
            return false;
        }
    }

    private function getDepth(node:Node, d:Int = 0)
    {
        if (node.left_path == null || node.left_path == null)
            return d;

        return Std.int(Math.max(getDepth(node.left_path.next_node, d + 1), getDepth(node.right_path.next_node, d + 1)));
    }

    private function dedup(data:Array<Dynamic>)
    {
        var out = [];
        for (i in data)
        {
            if (!out.has(i))
                out.push(i);
        }

        return out;
    }

    private function split(data:Array<Sample>, node:Node)
    {
        if (data.length <= 1)
            return;

        var possibleVariableValues = [];
        for (i in 0...data[0].variables.length)
        {
            var possibleValues = dedup(data.map(function(d) return d.variables[i]));
            if (possibleValues.length > 1)
            {
                for (n in possibleValues)
                    possibleVariableValues.push({variable: i, value: n});
            }
        }

        var min:Float = -1;
        var choosenValue = "";
        var variableChoosen = 0;

        var c:Condition =
        {
            variable_n: 0,
            variable_values: [],
        };
        for (i in possibleVariableValues)
        {
            c.variable_n = i.variable;
            c.variable_values = [i.value];
            var total = getImpurity(filterData(data, c, true)) + getImpurity(filterData(data, c, false));
            if (min == -1 || total < min)
            {
                min = total;
                choosenValue = i.value;
                variableChoosen = i.variable;
            }
        }

        var left_node = {end_value: 0};
        var right_node = {end_value: 0};

        var finalCondition = {
            variable_n: variableChoosen,
            variable_values: [choosenValue]
        };

        var left_path = {
            condition: finalCondition,
            next_node: left_node
        };
        var right_path = {
            condition: finalCondition,
            next_node: right_node
        };

        node.left_path = left_path;
        node.right_path = right_path;
        node.end_value = null;

        split(filterData(data, finalCondition, true), left_node);
        split(filterData(data, finalCondition, false), right_node);
    }

    public function filterData(data:Array<Sample>, condition:Condition, positive:Bool)
    {
        var out = [];
        for (i in data)
        {
            var value = i.variables[condition.variable_n];
            var has = condition.variable_values.has(value);
            if ((positive && has) || (!positive && !has))
                out.push(i);
        }

        return out;
    }

    public function getAVG(samples:Array<Sample>)
    {
        return samples.fold(function(sample, t) return t + sample.score, 0) / samples.length;
    }

    public inline function getImpurity(samples:Array<Sample>)
    {
        // Get average score
        var avg = samples.fold(function(sample, t) return t + sample.score, 0) / samples.length;

        return samples.fold(function(sample, total)
        {
            return total + Math.pow(avg - sample.score, 2);
        }, 0);
    }
}
