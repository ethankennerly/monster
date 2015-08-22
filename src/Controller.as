package 
{
    public class Controller
    {
        public static function listenToChildren(view:*, childNames:Array, methodName:String, owner:*):void
        {
            for (var c:int = 0; c < childNames.length; c++) 
            {
                var name:String = childNames[c];
                var child:* = view[name];
                View.listen(child, methodName, owner);
            }
        }

        /**
         * @param   changes     What is different as nested hashes.
         */
        public static function visit(parent:*, changes:Object, owner:* = null):void
        {
            throw new Error("TODO");
        }

    }
}
