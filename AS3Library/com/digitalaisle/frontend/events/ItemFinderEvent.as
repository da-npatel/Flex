package com.digitalaisle.frontend.events
{
	import flash.events.Event;
	
	public class ItemFinderEvent extends Event
	{
		public static const INIT:String = "init";
		public static const NEXT:String = "next";
		public static const PREV:String = "prev";
		
		private var _currentPosition:int;
		private var _mode:String;
		private var _data:Object;
		
		public function ItemFinderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, mode:String = "", data:Object = null, currentPosition:int = 0)
		{
			_mode = mode;
			_currentPosition = currentPosition;
			_data = data;
			super(type, bubbles, cancelable);
			
		}
		
		public override function clone():Event 
		{ 
			return new ItemFinderEvent(type, bubbles, cancelable, _mode, _currentPosition);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ItemFinderEvent", "type", "bubbles", "cancelable", "eventPhase", "result"); 
		}
		
		public function get currentPosition():int
		{
			return _currentPosition;
		}
		
		public function get mode():String
		{
			return _mode;
		}

		public function get data():Object
		{
			return _data;
		}

		public function set data(value:Object):void
		{
			_data = value;
		}

	}
}