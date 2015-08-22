package 
{
    /**
     * Portable.
     */
    public class Stopwatch
    {
        public var deltaSeconds:Number = 0;
        public var milliseconds:int = -1;
        public var millisecondsPreviously:int = -1;
        public var onUpdate:Function;

        /**
         * @param   changes     What is different as nested hashes.
         */
        public function update(event:*):void
        {
            milliseconds = View.getMilliseconds();
            deltaSeconds = 0.001 * (milliseconds - millisecondsPreviously);
            if (null != onUpdate)
            {
                onUpdate(deltaSeconds);
            }
            millisecondsPreviously = milliseconds;
        }
    }
}
