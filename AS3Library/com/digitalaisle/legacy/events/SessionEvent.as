package com.digitalaisle.legacy.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Digital Aisle
	 */
	public class SessionEvent extends Event 
	{
		public static const CONFIRM_START:String = "confirmStart";				// event fires when confirmation popup starts
		
		public static const SESSION_PAUSE:String = "sessionPause";				// event fires when session is paused
		public static const SESSION_PLAY:String = "sessionPlay";				// event fires when session is unpaused
		
		public static const START_SESSION:String = "startSession";				// event fires when session started
		public static const END_SESSION:String = "endSession";					// event fires when session ends

		//public static const RESULT:String = "result";							// event fires when result returned

		public static const RESET_TIMER:String = "reset";						// event fires when main timer is reset
		
		public static const COUNTDOWN:String = "countdown";						// fires on each tick of the confirmation timer
		public static const SERVICE_RESULT:String = "serviceResult";
		
		public var result:String;
		
		public function SessionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, serviceResult:String = "none") 
		{ 
			result = serviceResult;
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new SessionEvent(type, bubbles, cancelable, result);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("SessionEvent", "type", "bubbles", "cancelable", "eventPhase", "result"); 
		}
		
	}	
}