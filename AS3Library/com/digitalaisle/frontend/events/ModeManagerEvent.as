package com.digitalaisle.frontend.events
{
	import flash.events.Event;
	
	public class ModeManagerEvent extends Event
	{
		public static const NEXT:String = "next";
		public static const PREV:String = "prev";
		
		private var _currentPosition:int;
		private var _mode:int;
		
		public function ModeManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, mode:int = 0, currentPosition:int = 0)
		{
			_mode = mode;
			_currentPosition = currentPosition;
			super(type, bubbles, cancelable);
			
		}
		
		public override function clone():Event 
		{ 
			return new ModeManagerEvent(type, bubbles, cancelable, _mode, _currentPosition);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ModeManagerEvent", "type", "bubbles", "cancelable", "eventPhase", "result"); 
		}

		public function get currentPosition():int
		{
			return _currentPosition;
		}

		public function get mode():int
		{
			return _mode;
		}


	}
}