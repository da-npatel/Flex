package com.digitalaisle.frontend.events
{
	import flash.events.Event;
	
	public class DataManagerEvent extends Event
	{
		public static const THEME_LOADED:String = "themeLoaded";
		public static const LOADING_COMPLETE:String = "loadingComplete";
		public static const LAZY_LOADING_COMPLETE:String = "lazyLoadingComplete";
		
		public function DataManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
			
		public override function clone():Event 
		{ 
			return new DataManagerEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("DataManagerEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}