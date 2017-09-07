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
    var score: Int;
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
        split(data, main_node);

        trace(getDepth(main_node));
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
        if (data.length == 0)
            return;

        var differentValues = dedup(data.map(function (d) return d.variables.join(",")));
        if (differentValues.length == 1)
            return;

        var possibleValues = [];
        var variableChoosen = 0;
        while (possibleValues.length < 1)
        {
            variableChoosen = Std.random(data[0].variables.length);
            possibleValues = dedup(data.map(function(d) return d.variables[variableChoosen]));
        }

        var min:Float = -1;
        var choosenValue = "";

        var c:Condition =
        {
            variable_n: variableChoosen,
            variable_values: [],
        };
        for (i in possibleValues)
        {
            c.variable_values = [i];
            var total = getImpurity(filterData(data, c, true)) + getImpurity(filterData(data, c, false));
            if (min == -1 || total < min)
            {
                min = total;
                choosenValue = i;
            }
        }

        var left_node = {end_value: 0
        };

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

    public function getImpurity(samples:Array<Sample>)
    {
        // Get average score
        var avg = samples.fold(function(sample, t) return t + sample.score, 0) / samples.length;

        return samples.fold(function(sample, total)
        {
            return total + Math.pow(avg - sample.score, 2);
        }, 0);
    }
}
