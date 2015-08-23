package 
{
    /**
     * Portable.  Independent of Flash.
     */
    public class MonsterModel
    {
        internal var cityNames:Array;
        internal var changes:Object;
        internal var population:int;
        internal var represents:Object;
        internal var result:int = 0;

        private var vacancy:int;
        private var cellWidth:int;
        private var cellHeight:int;
        private var width:int;
        private var height:int;
        private var widthInCells:int;
        private var heightInCells:int;
        private var period:Number = 2.0;
        private var accumulated:Number = 0.0;
        private var selectCount:int = 0;

        private var grid:Array = [];
        private var gridPreviously:Array = [];

        public function MonsterModel()
        {
        }

        private function initGrid(grid:Array, cellWidth:int, cellHeight:int):void
        {
            this.cellWidth = Math.ceil(cellWidth);
            this.cellHeight = Math.ceil(cellHeight);
            widthInCells = Math.floor(width / cellWidth);
            heightInCells = Math.floor(height / cellHeight);
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
                            changes[name] = {x: cellWidth * column + cellWidth / 2,
                                y: cellHeight * row + cellHeight / 2,
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
                if (1 <= selectCount)
                {
                    if (population <= 2) 
                    {
                        randomlyPlace(grid);
                    }
                    grid = grow(grid);
                }
                population = sum(grid);
                vacancy = grid.length - population;
                period = updatePeriod(population, vacancy);
            }
            changes = change(gridPreviously, grid);
            cityNames = Model.keys(changes, "city");
            win();
            gridPreviously = grid.concat();
        }

        private function sum(counts:Array):int
        {
            var sum:int = 0;
            for (var c:int = 0; c < counts.length; c++)
            {
                sum += counts[c];
            }
            return sum;
        }

        private var startingPlaces:int = 2;

        /**
         * Slow to keep trying if there were lot of starting places, but there aren't.
         */
        private function randomlyPlace(grid:Array):void
        {
            for (var s:int = 0; sum(grid) < startingPlaces; s++)
            {
                var index:int = Math.floor(Math.random() * (grid.length - 4)) + 2;
                grid[index] = 1;
            }
            // startingPlaces++;
        }

        // 120.0;
        // 60.0;
        // 40.0;
        // 20.0;
        private var periodBase:int = 80.0;

        private function updatePeriod(population:int, vacancy:int):Number
        {
            var period:Number = 999999.0;
            if (population <= 0)
            {
                periodBase = Math.max(10, periodBase - 10);
                period = periodBase * 0.05;
            }
            else if (1 <= vacancy)
            {
                var ratio:Number = population / vacancy;
                var exponent:Number = 1.0;
                // 0.75;
                // 0.25;
                // 1.0;
                // 0.25;
                var power:Number = Math.pow(ratio, exponent);
                period = power * periodBase;
            }
            return period;
        }

        private function win():void
        {
            if (vacancy <= 0)
            {
                result = -1;
            }
            else if (population <= 0)
            {
                result = 1;
            }
            else
            {
                result = 0;
            }
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
            selectCount++;
            grid[row * widthInCells + column] = 0;
        }
    }
}
