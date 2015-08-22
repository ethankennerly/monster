package 
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.events.MouseEvent;

    public class View
    {
        /**
         * @return Hash of uniquely named descendents.  key:  name.  values:  {x, y}
         */
        public static function represent(child:DisplayObject):Object
        {
            var represents:Object = {};
            represents.x = getPositionX(child);
            represents.y = getPositionY(child);
            if (child is DisplayObjectContainer)
            {
                var parent:DisplayObjectContainer = DisplayObjectContainer(child);
                for (var c:int = 0; c < parent.numChildren; c++)
                {
                    var child:DisplayObject = parent.getChildAt(c);
                    var name:String = child.name;
                    if (name && 0 !== name.indexOf("instance"))
                    {
                        if (name in represents) 
                        {
                            throw new Error("Expected each name was unique.  Duplicated " + name);
                        }
                        represents[name] = represent(child);
                    }
                }
            }
            return represents;
        }

        /**
         * @param   methodName  and owner avoids JavaScript bind.
         */
        public static function listen(child:DisplayObjectContainer, methodName:String, owner:*):Boolean
        {
            var isListening:Boolean = false;
            if (child) 
            {
                var method:Function = owner[methodName];
                child.addEventListener(MouseEvent.CLICK, method);
            }
            return isListening;
        }

        public static function currentTarget(event:Event):*
        {
            return event.currentTarget;
        }

        public static function setVisible(child:DisplayObject, isVisible:Boolean):void
        {
            child.visible = isVisible;
        }

        public static function getPositionX(child:DisplayObject):Number
        {
            return child.x;
        }

        public static function getPositionY(child:DisplayObject):Number
        {
            return child.y;
        }
    }
}
