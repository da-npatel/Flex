package com.digitalaisle.frontend.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Digital Aisle
	 */
	public class SessionEvent extends Event 
	{
		public static const TIMEOUT:String = "timeout";
		public static const SESSION_ENDED:String = "sessionEnded";					// event fires when session ends
		public static const SESSION_PAUSED:String = "sessionPaused";
		public static const SESSION_RESUMED:String = "sessionResumed";
		
		public static const COUNTDOWN:String = "countdown";						// fires on each tick of the confirmation timer
		
		public function SessionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new SessionEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("SessionEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}	
}