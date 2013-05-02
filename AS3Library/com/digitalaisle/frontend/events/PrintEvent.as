package com.digitalaisle.frontend.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Digital Aisle
	 */
	public class PrintEvent extends Event 
	{
		public static const PRINT_READY:String = "printReady";
		public static const PRINT_COMPLETE:String = "printCompelete";
		public static const PRINT_FAIL:String = "printFail";

		public function PrintEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			
			super(type, bubbles, cancelable);
			trace("PRINT EVENT");
		} 
		
		public override function clone():Event 
		{ 
			return new PrintEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PrintEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}