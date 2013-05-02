package com.digitalaisle.frontend.events
{
	import flash.events.Event;
	
	public class AvatarEvent extends Event {
		
		public static const LOAD:String = "load";
		public var source:String;
		public var autoPlay:Boolean;
		
		public function AvatarEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, source:String = "", autoPlay:Boolean = false) {			
			this.source = source;
			this.autoPlay = autoPlay;
			super(type, bubbles, cancelable);
		}	
	
		public override function clone():Event { 
			return new AvatarEvent(LOAD, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("AvatarEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}