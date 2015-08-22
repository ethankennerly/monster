package 
{
    /**
     * Portable.  Independent of Flash.
     */
    public class MonsterModel
    {
        internal var represents:Object;
        internal var cityNames:Array;

        public function MonsterModel()
        {
        }

        internal function represent(represents:Object):void
        {
            this.represents = represents;
            this.cityNames = Model.keys(represents, "city");
        }
    }
}
