package 
{
    import flash.events.Event;
    import flash.display.Sprite;

    public class Main extends Sprite
    {
        private var controller:MonsterController;

        public function Main()
        {
            if (stage) 
            {
                init(null);
            }
            else 
            {
                addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
            }
        }

        private function init(e:Event):void
        {
            var view:MainScene = new MainScene();
            addChild(view);
            controller = new MonsterController(view);
        }
    }
}
