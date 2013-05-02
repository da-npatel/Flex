package com.digitalaisle.frontend.core.keypad.keys
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	//Change MX Image to Spark Image - Start
	//import mx.controls.Image;
	import spark.components.Image;
	//End
	import mx.core.BitmapAsset;
	import mx.core.FlexBitmap;
	
	import spark.primitives.BitmapImage;
	import spark.utils.BitmapUtil;

	public class Icon extends Key
	{
		[SkinPart(required="false")]
		public var iconDisplay:BitmapImage;
		
		private var _iconBitmap:BitmapData;
		
		public function Icon()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == iconDisplay)
			{
				iconDisplay.source = _iconBitmap
			}
		}

		public function get iconBitmap():BitmapData
		{
			return _iconBitmap;
		}

		public function set iconBitmap(value:BitmapData):void
		{
			_iconBitmap = value;
		}

		
	}
}