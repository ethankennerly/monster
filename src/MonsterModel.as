package 
{
    /**
     * Portable.  Independent of Flash.
     */
    public class MonsterModel
    {
        internal var cityNames:Array;
        internal var changes:Object;
        internal var represents:Object;
        private var cellWidth:int;
        private var cellHeight:int;
        private var width:int;
        private var height:int;
        private var widthInCells:int;
        private var heightInCells:int;
        private var period:Number = 2.0;
        private var accumulated:Number = 0.0;

        private var grid:Array = [];
        private var gridPreviously:Array = [];

        public function MonsterModel()
        {
        }

        private function initGrid(grid:Array, cellWidth:int, cellHeight:int):void
        {
            this.cellWidth = Math.ceil(cellWidth);
            this.cellHeight = Math.ceil(cellHeight);
            widthInCells = Math.ceil(width / cellWidth);
            heightInCells = Math.ceil(height / cellHeight);
            grid.length = 0;
            for (var row:int = 0; row < heightInCells; row++)
            {
                for (var column:int = 0; column < widthInCells; column++)
                {
                    grid.push(0);
                }
            }
            gridPreviously = grid.concat();
        }

        private function toGrid(represents:Object, cityNames:Array):Array
        {
            width = Math.ceil(represents.width);
            height = Math.ceil(represents.height);
            for (var c:int = 0; c < cityNames.length; c++)
            {
                var name:String = cityNames[c];
                var child:* = represents[name];
                if (0 == grid.length) {
                    initGrid(grid, child.width, child.height);
                }
                var column:int = Math.floor(child.x / cellWidth);
                var row:int = Math.floor(child.y / cellHeight);
                grid[row * widthInCells + column] = 1;
            }
            trace(grid);
            return grid;
        }

        internal function represent(represents:Object):void
        {
            this.represents = represents;
            cityNames = Model.keys(represents, "city");
            grid = toGrid(represents, cityNames);
        }

        private function expand(grid:Array, row:int, column:int, gridNext:Array):void
        {
            var index:int = (row) * widthInCells + column;
            var cell:int = grid[index];
            if (1 == cell)
            {
                if (0 < row)
                {
                    gridNext[(row-1) * widthInCells + column] = 1;
                }
                if (0 < column)
                {
                    gridNext[(row) * widthInCells + column - 1] = 1;
                }
                if (row < heightInCells - 1)
                {
                    gridNext[(row+1) * widthInCells + column] = 1;
                }
                if (column < widthInCells - 1)
                {
                    gridNext[(row) * widthInCells + column + 1] = 1;
                }
            }
        }

        private function grow(grid:Array):Array
        {
            var gridNext:Array = grid.concat();
            for (var row:int = 0; row < heightInCells; row++)
            {
                for (var column:int = 0; column < widthInCells; column++)
                {
                    expand(grid, row, column, gridNext);
                }
            }
            return gridNext;
        }

        private function change(gridPreviously, grid):Object
        {
            var changes:Object = {};
            for (var row:int = 0; row < heightInCells; row++)
            {
                for (var column:int = 0; column < widthInCells; column++)
                {
                    var index:int = row * widthInCells + column;
                    if (grid[index] !== gridPreviously[index]) {
                        var name:String = "city_" + row + "_" + column;
                        if (1 == grid[index]) 
                        {
                            changes[name] = {x: cellWidth * column,
                                y: cellHeight * row,
                                visible: true};
                        }
                        else
                        {
                            changes[name] = {visible: false};
                        }
                    }
                }
            }
            return changes;
        }

        internal function update(deltaSeconds:Number):void
        {
            accumulated += deltaSeconds;
            if (period <= accumulated) 
            {
                accumulated -= period;
                grid = grow(grid);
            }
            changes = change(gridPreviously, grid);
            cityNames = Model.keys(changes, "city");
            gridPreviously = grid.concat();
        }

        internal function select(name:String):void
        {
            var parts:Array = name.split("_");
            var row:int = parseInt(parts[1]);
            var column:int = parseInt(parts[2]);
            selectCell(row, column);
        }

        internal function selectCell(row:int, column:int):void
        {
            grid[row * widthInCells + column] = 0;
        }
    }
}
