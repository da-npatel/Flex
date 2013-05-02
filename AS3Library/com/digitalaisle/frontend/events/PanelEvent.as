package com.digitalaisle.frontend.events
{
	import flash.events.Event;
	
	public class PanelEvent extends Event
	{
		public static const IS_READY:String = "isReady";
		public static const COMPLETE:String = "complete";
		public static const CLICK:String = "panelClick";
		public static const SINGLE_CLICK:String = "singleClick";
		public static const DOUBLE_CLICK:String = "doubleClick";
		public static const BUILD_ON_START:String = "buildOnStart";
		public static const BUILD_ON_END:String = "buildOnEnd";
		public static const BUILD_OFF_START:String = "buildOffStart";
		public static const BUILD_OFF_END:String = "buildOffEnd";
		public static const DISABLE_NEXT:String = "disableNext";
		public static const DISABLE_PREV:String = "disablePrev";
		public static const SCROLL_DISABLED:String = "scrollDisabled";
		public static const SCROLL_ENABLED:String = "scrollEnabled";
		
		
		public function PanelEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event 
		{ 
			return new PanelEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PanelEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}