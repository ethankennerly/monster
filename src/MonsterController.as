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
            Controller.listenToChildren(view, model.cityNames, "select", this);
        }

        public function select(event:*):void
        {
            View.setVisible(View.currentTarget(event), false);
        }
    }
}
