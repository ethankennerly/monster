package 
{
    /**
     * Portable.  Independent of Flash.
     */
    public class MonsterController
    {
        private var model:MonsterModel;
        private var view:*;

        public function MonsterController(view:*)
        {
            this.view = view;
            this.model = new MonsterModel();
            this.model.represent(View.represent(view));
            for (var c:int = 0; c < model.cityNames.length; c++)
            {
                var name:String = model.cityNames[c];
                View.setVisible(view[name], false);
            }
        }

        public function select(event:*):void
        {
            model.select(View.getName(View.currentTarget(event)));
        }

        private function updateText(result:int):void
        {
            View.setText(view.countText, model.population.toString());
            if (result != 0)
            {
                var text:String;
                if (result == 1) 
                {
                    text = "The infection has been obliterated.";
                }
                else
                {
                    text = "Humans have domesticated the entire planet.";
                }
                View.setText(view.text, text);
            }
        }

        internal function update(deltaSeconds:Number):void
        {
            model.update(deltaSeconds);
            Controller.visit(view, model.changes, createCity);
            Controller.listenToChildren(view, model.cityNames, "select", this);
            updateText(model.result);
        }

        internal function createCity(child:*, key:String, change:*):Object
        {
            if (child)
            {
            }
            else
            {
                child = new City();
                View.addChild(view, child, key);
            }
            return child;
        }
    }
}
