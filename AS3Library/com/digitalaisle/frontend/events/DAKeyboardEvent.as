package com.digitalaisle.frontend.events
{
	import flash.events.Event;
	
	public class DAKeyboardEvent extends Event
	{
		public static const OPEN:String = "open";
		public static const CLOSE:String = "close";
		public static const KEY_PRESSED:String = "keyPressed";
		
		private var _keyValue:String;
		private var _keyFunction:String;
		
		public function DAKeyboardEvent(type:String, keyFunction:String, keyValue:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_keyFunction = keyFunction;
			_keyValue = keyValue;
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event { 
			return new DAKeyboardEvent(type, _keyFunction, _keyValue, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("DAKeyboardEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}

		public function get keyValue():String
		{
			return _keyValue;
		}

		public function get keyFunction():String
		{
			return _keyFunction;
		}


	}
}