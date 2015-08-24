package 
{
    import flash.events.Event;
    import flash.display.Sprite;
    import flash.geom.Rectangle;

    public class Main extends Sprite
    {
        private var controller:MonsterController;
        private var stopwatch:Stopwatch;

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
            scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
            var view:MainScene = new MainScene();
            addChild(view);
            controller = new MonsterController(view);
            var stopwatch:Stopwatch = new Stopwatch();
            stopwatch.onUpdate = controller.update;
            View.listen(this, "update", stopwatch, Event.ENTER_FRAME);
        }
    }
}
