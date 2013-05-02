package com.digitalaisle.uilibrary.components
{
	import com.digitalaisle.frontend.utils.ApplicationUtil;
	
	import flash.events.Event;
	
	import spark.components.HSlider;
	import spark.events.TrackBaseEvent;
	
	public class VolumeSlider extends HSlider
	{
		
		
		public function VolumeSlider()
		{
			super();
			
			addEventListener(TrackBaseEvent.THUMB_DRAG, onValueChange, false, 0, true);
			minimum = 0;
			maximum = 100;
			value = ApplicationUtil.systemVolume * 100;
		}
		
		
		private function onValueChange(e:TrackBaseEvent):void
		{
			ApplicationUtil.systemVolume = (e.target.value / 100 );
		}
		
	}
}