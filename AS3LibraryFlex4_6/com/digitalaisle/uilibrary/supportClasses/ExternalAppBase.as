package com.digitalaisle.uilibrary.supportClasses
{
	import com.digitalaisle.frontend.enums.BinaryType;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import mx.controls.SWFLoader;
	import mx.events.FlexEvent;

	public class ExternalAppBase extends ModuleBase
	{
		[SkinPart(required="true")]
		public var swfLoader:SWFLoader;
		
		private var _swfLocation:String;
		
		public function ExternalAppBase()
		{
			super();
		}
		
		override protected function onPreInitialize(e:FlexEvent):void
		{
			super.onPreInitialize(e);
			
			_swfLocation = projectContentItem.fetchBinaryContentByType(BinaryType.FLASH_APP);
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance) {
				case swfLoader:
					swfLoader.addEventListener(IOErrorEvent.IO_ERROR, onSwfLoadError, false, 0, true);
					swfLoader.load(_swfLocation);
					break;
			}
		}
		
		protected function onSwfLoadError(e:IOErrorEvent):void
		{
			
		}
	}
}