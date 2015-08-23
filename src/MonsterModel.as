package 
{
    /**
     * Portable.  Independent of Flash.
     */
    public class MonsterModel
    {
        internal var cityNames:Array;
        internal var level:int = 1;
        internal var length:int;
        internal var changes:Object;
        internal var population:int;
        internal var represents:Object;
        internal var result:int = 0;
        internal var selectCount:int = 0;
        internal var isWinNow:Boolean;

        private var vacancy:int;
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
            var isometricHeightMultiplier:Number = 0.5;
            // 0.5;
            // 1.0; 
            cellHeight = Math.ceil(cellHeight * isometricHeightMultiplier);
            this.cellHeight = cellHeight;
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
            width = Math.ceil(represents.spawnArea.width);
            height = Math.ceil(represents.spawnArea.height);
            for (var c:int = 0; c < cityNames.length; c++)
            {
                var name:String = cityNames[c];
                var child:* = represents.spawnArea[name];
                if (0 == grid.length) {
                    initGrid(grid, child.width, child.height);
                }
                var column:int = Math.floor(child.x / cellWidth);
                var row:int = Math.floor(child.y / cellHeight);
                grid[row * widthInCells + column] = 1;
            }
            length = grid.length;
            trace(grid);
            return grid;
        }

        internal function represent(represents:Object):void
        {
            this.represents = represents;
            cityNames = Model.keys(represents.spawnArea, "city");
            grid = toGrid(represents, cityNames);
            if (sum(grid) <= 0)
            {
                randomlyPlace(grid);
            }
        }

        /**
         *
            Torri expects isometric grid.
                Represent grid with offsets:  
                    Expand:  Neighbor is up and down, up-left and down-left (if even), up-right, down-right (if odd).
                    Layout each odd indexed row with an offset right.
                        2 2 2
                         1 1 3
                        2 0 2
                         1 1 3
         */
        private function expandIsometric(grid:Array, row:int, column:int, gridNext:Array):void
        {
            var index:int = (row) * widthInCells + column;
            var cell:int = grid[index];
            if (1 == cell)
            {
                var offset:int = row % 2;
                var columnOffset:int = offset == 0 ? -1 : 1;
                if (0 < row)
                {
                    var up:int = (row-1) * widthInCells + column;
                    gridNext[up] = 1;
                    if (0 < column + offset)
                    {
                        gridNext[up + columnOffset] = 1;
                    }
                }
                if (row < heightInCells - 1)
                {
                    var down:int = (row+1) * widthInCells + column;
                    gridNext[down] = 1;
                    if (column + offset < widthInCells - 1)
                    {
                        gridNext[down + columnOffset] = 1;
                    }
                }
            }
        }

        private function expandTopDown(grid:Array, row:int, column:int, gridNext:Array):void
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
                    expandIsometric(grid, row, column, gridNext);
                }
            }
            return gridNext;
        }

        private function offsetWidth(row:int):Number
        {
            return (row % 2) * cellWidth * 0.5;
        }

        private function change(gridPreviously:Array, grid:Array):Object
        {
            var changes:Object = {};
            var count:int = 0;
            for (var row:int = 0; row < heightInCells; row++)
            {
                for (var column:int = 0; column < widthInCells; column++)
                {
                    var index:int = row * widthInCells + column;
                    if (grid[index] !== gridPreviously[index]) {
                        if (null == changes.spawnArea)
                        {
                            changes.spawnArea = {};
                        }
                        var name:String = "city_" + row + "_" + column;
                        count++;
                        if (1 == grid[index]) 
                        {
                            changes.spawnArea[name] = {x: cellWidth * column + cellWidth * 0.5 + offsetWidth(row),
                                y: cellHeight * row + cellHeight * 0.5,
                                visible: true};
                        }
                        else
                        {
                            changes.spawnArea[name] = {visible: false};
                        }
                    }
                }
            }
            return changes;
        }

        internal function update(deltaSeconds:Number):Boolean
        {
            accumulated += deltaSeconds;
            population = sum(grid);
            vacancy = grid.length - population;
            if (period <= accumulated) 
            {
                accumulated = 0;
                if (1 <= selectCount)
                {
                    grid = grow(grid);
                    if (population <= 3) 
                    {
                        randomlyPlace(grid);
                    }
                }
                period = updatePeriod(population, vacancy);
            }
            changes = change(gridPreviously, grid);
            cityNames = Model.keys(changes.spawnArea, "city");
            gridPreviously = grid.concat();
            return win();
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
        // 2;

        /**
         * Slow to keep trying if there were lot of starting places, but there aren't.
         */
        private function randomlyPlace(grid:Array):void
        {
            var attemptMax:int = 128;
            for (var attempt:int = 0; sum(grid) < startingPlaces && attempt < attemptMax; attempt++)
            {
                var index:int = Math.floor(Math.random() * (grid.length - 4)) + 2;
                grid[index] = 1;
            }
            // startingPlaces++;
        }

        // 120.0;
        // 90.0;
        // 80.0;
        // 60.0;
        // 40.0;
        // 20.0;
        private var periodBase:int = 120.0;

        private function updatePeriod(population:int, vacancy:int):Number
        {
            var period:Number = 999999.0;
            if (population <= 0)
            {
                periodBase = Math.max(5, periodBase * 0.9);
                period = 4.0 + 5.0 / level;
                accumulated = 0;
                // periodBase * 0.05;
                level++;
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

        private function win():Boolean
        {
            isWinNow = result !== 1;
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
            isWinNow = isWinNow && result === 1;
            return isWinNow;
        }

        internal function select(name:String):Boolean
        {
            var parts:Array = name.split("_");
            var row:int = parseInt(parts[1]);
            var column:int = parseInt(parts[2]);
            var result:int = selectCell(row, column);
            population = sum(grid);
            var isExplosion:Boolean = 1 === result;
            if (isExplosion && 1 <= population)
            {
                vacancy = grid.length - population;
                period = updatePeriod(population, vacancy);
            }
            return isExplosion;
        }

        internal function selectCell(row:int, column:int):int
        {
            var index:int = row * widthInCells + column;
            var was:int = grid[index];
            if (1 == was)
            {
                selectCount++;
                grid[index] = 0;
            }
            return was;
        }
    }
}
