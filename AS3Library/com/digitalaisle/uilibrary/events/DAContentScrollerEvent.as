package com.digitalaisle.uilibrary.events
{
	import flash.events.Event;
	
	public class DAContentScrollerEvent extends Event
	{
		public static const SCROLL_STOPPED:String = "scrollStopped";
		
		public function DAContentScrollerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event 
		{ 
			return new DAContentScrollerEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("DAContentScrollerEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}