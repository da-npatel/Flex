package com.digitalaisle.frontend.events {
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	
	import flash.events.Event;
	
	public class DASlideshowEvent extends Event {
		
		public static const CLICK:String = "slideshowclick";
		public static const CHANGE:String = "slidechange";
		
		public var pci:ProjectContentItem;
		
		public function DASlideshowEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event { 
			return new DASlideshowEvent(CLICK, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("DASlideshowEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}