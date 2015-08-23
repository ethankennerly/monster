package 
{
    /**
     * Portable.  Independent of Flash.
     */
    public class MonsterController
    {
        private var model:MonsterModel;
        private var view:*;
        private var classNameCounts:Object;
        private var pools:Object;
        private var explosionSoundCount:int = 4;

        public function MonsterController(view:*)
        {
            this.view = view;
            model = new MonsterModel();
            model.represent(View.represent(view));
            classNameCounts = {
                "City": model.length,
                "Explosion": model.length
            }
            pools = Pool.construct(View.construct, classNameCounts);
            for (var c:int = 0; c < model.cityNames.length; c++)
            {
                var name:String = model.cityNames[c];
                View.removeChild(view.spawnArea[name]);
                // View.setVisible(view.spawnArea[name], false);
            }
            View.initAnimation(view.win);
        }

        public function select(event:*):void
        {
            var target:* = View.currentTarget(event);
            var isExplosion:Boolean = model.select(View.getName(target));
            if (isExplosion)
            {
                var index:int = pools["Explosion"].index;
                var explosion:* = pools["Explosion"].next();
                var parent:* = View.getParent(target);
                View.addChild(parent, explosion, "explosion_" + index);
                View.setPosition(explosion, View.getPosition(target));
                View.start(explosion);
                var countingNumber:int = Math.floor(Math.random() * explosionSoundCount) + 1;
                View.playSound("explosion_0" + countingNumber);
            }
        }

        private function updateText(result:int):void
        {
            View.setText(view.countText, model.selectCount.toString());
            View.setText(view.levelText, model.level.toString());
            var text:String;
            if (result == 1) 
            {
                text = "YOU WIN!  Humans have been obliterated ... for now.";
            }
            else if (result == -1)
            {
                text = "Humans have domesticated the entire planet.";
            }
            else
            {
                text = "Mother Nature:\nDestroy all humans before they ruin you!\nDraw to destroy cities.";
            }
            View.setText(view.text, text);
        }

        internal function update(deltaSeconds:Number):void
        {
            model.update(deltaSeconds);
            if (model.isWinNow)
            {
                View.start(view.win);
            }
            Controller.visit(view, model.changes, createCity);
            updateText(model.result);
        }
       
        function randomRange(minNum:Number, maxNum:Number):Number 
        {
            return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
        }

        /**
         * Would be more flexible to add child to whichever parent.
         */
        internal function createCity(child:*, key:String, change:*):Object
        {
            if (child)
            {
            }
            else
            {
                if (Controller.isObject(change) && change.x && key.indexOf("city") === 0)
                {
                    child = pools["City"].next();
                    View.gotoFrame(child, randomRange(1, child.totalFrames));
                    var parent = view.spawnArea;
                    View.addChild(parent, child, key);
                    View.listenToOverAndDown(child, "select", this);
                }
            }
            return child;
        }
    }
}
