package com.digitalaisle.frontend.events {
	import flash.events.Event;
	
	public class DAValueSliderEvent extends Event {
		
		public static const CHANGED:String = "valuesliderchanged";
		
		public function DAValueSliderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event { 
			return new DAValueSliderEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("DAValueSliderEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}