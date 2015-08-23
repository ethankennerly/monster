package 
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.utils.getTimer;

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
            represents.width = getWidth(child);
            represents.height = getHeight(child);
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
        public static function listen(child:DisplayObjectContainer, methodName:String, owner:*, eventType:String = null):Boolean
        {
            if (null == eventType)
            {
                eventType = MouseEvent.MOUSE_OVER;
            }
            var isListening:Boolean = false;
            if (child) 
            {
                var method:Function = owner[methodName];
                child.addEventListener(eventType, method);
            }
            return isListening;
        }

        public function listenToUpdate(child:DisplayObjectContainer, methodName:String, owner:*):Boolean
        {
            return listen(child, methodName, owner, Event.ENTER_FRAME);
        }

        public static function listenToOverAndDown(child:DisplayObjectContainer, methodName:String, owner:*):Boolean
        {
            return View.listen(child, methodName, owner)
                && View.listen(child, methodName, owner, MouseEvent.MOUSE_DOWN);
        }

        public static function currentTarget(event:Event):*
        {
            return event.currentTarget;
        }

        public static function getName(child:*):*
        {
            return child.name;
        }

        public static function setVisible(child:DisplayObject, isVisible:Boolean):void
        {
            child.visible = isVisible;
        }

        public static function getWidth(child:DisplayObject):Number
        {
            return child.width;
        }

        public static function getHeight(child:DisplayObject):Number
        {
            return child.height;
        }

        public static function getPositionX(child:DisplayObject):Number
        {
            return child.x;
        }

        public static function getPositionY(child:DisplayObject):Number
        {
            return child.y;
        }

        public static function setPositionX(child:DisplayObject, x:Number):void
        {
            child.x = x;
        }

        public static function setPositionY(child:DisplayObject, y:Number):void
        {
            child.y = y;
        }

        public static function setText(child:TextField, text:String):void
        {
            child.text = text;
        }

        public static function getMilliseconds():int
        {
            return getTimer();
        }

        public static function addChild(parent:DisplayObjectContainer, child:DisplayObject, name:String):void
        {
            parent.addChild(child);
            parent[name] = child;
            child.name = name;
        }

        public static function removeChild(child:DisplayObject):void
        {
            var parent:DisplayObjectContainer = child.parent;
            if (null != parent)
            {
                if (child.name && parent[child.name] === child)
                {
                    delete parent[child.name];
                }
                parent.removeChild(child);
            }
        }
    }
}
