package com.digitalaisle.uilibrary.events
{
	import flash.events.Event;
	
	public class EmailPadEvent extends Event
	{
		public static const EMAIL_SENT:String = "emailSent";
		public static const EMAIL_FAILED:String = "emailFailed";
		
		public function EmailPadEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event 
		{ 
			return new EmailPadEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("EmailPadEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}