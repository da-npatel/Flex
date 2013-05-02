package com.digitalaisle.frontend.events
{
	import flash.events.Event;
	
	public class AttractorEvents extends Event
	{
		public static const SLIDE_END:String = "slide_end";				// event fires when slide is complete
		public static const SLIDE_START:String = "slide_start";				// event fires when slide is ready to play/view
		public static const VIDEO_END:String = "video_end";				// event fires when video is complete

		public function AttractorEvents(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			trace("fire AttrEvent: "+type);
			super(type, bubbles, cancelable);
		}
	}
}