package com.digitalaisle.frontend.events
{
	import flash.events.Event;
	
	public class FontManagerEvent extends Event
	{
		public static const COMPLETE:String = "complete";
		
		public function FontManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event 
		{ 
			return new FontManagerEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("FontManagerEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}