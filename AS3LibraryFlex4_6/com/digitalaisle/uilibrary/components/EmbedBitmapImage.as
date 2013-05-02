package com.digitalaisle.uilibrary.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import spark.components.Group;
	import spark.primitives.BitmapImage;
	
	[Style(name="imageBitmap", type="flash.dispaly.Bitmap", inherit="yes")]
	
	public class EmbedBitmapImage extends Group
	{
		protected var image:BitmapImage;
		
		public function EmbedBitmapImage()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			image = new BitmapImage();
			image.width = width;
			image.height = height;
			addElement(image);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var bitmapData:BitmapData;
			if(getStyle("imageBitmap"))
			{
				if(getStyle("imageBitmap") is Class){
					bitmapData = createBitmapFromClass(getStyle("imageBitmap")).bitmapData;
				} else if(getStyle("imageBitmap") is Bitmap) {
					bitmapData =  (getStyle("imageBitmap") as Bitmap).bitmapData;
				}	
				
				if(image.source) {
					if(image.source.width === bitmapData.width) {
						return;
					}else {
						image.source = bitmapData;
					}
				}else {
					image.source = bitmapData;
				}
				
			}
		}
		
		private function createBitmapFromClass(BitmapClass:Class):Bitmap
		{
			var btnBitmap:Bitmap = new BitmapClass();
			btnBitmap.smoothing = true;
			return btnBitmap;
		}
		
		
		override public function set width(value:Number):void
		{
			super.width = value;
			if(image)
				image.width = value;
		}
		
		override public function set height(value:Number):void
		{
			super.height = value;
			if(image)
				image.height = value;
		}
		
		/*public function set source(value:Object):void
		{
			trace(value);
			if(image)
				image.source = value;
		}*/
	}
}