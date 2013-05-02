package com.digitalaisle.frontend.drawing
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class DynamicShape extends Sprite
	{
		
		public function DynamicShape()
		{
			super();
		}
		
		// CREATES a rectanglular object
		public function doDrawRect(width:Number, height:Number, color:uint = 0x333333, alpha:Number = 1, label:String = null):void
		{
			graphics.beginFill(color, alpha);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
			if(label)
			{
				var text:TextField = new TextField();
				text.width = width;
				text.text = label;
				text.autoSize = TextFieldAutoSize.CENTER;
				text.y  = height * .5;
				addChild(text);
			}
		}
		
		
		
		
		/*private function doDrawCircle():void {
		var child:Shape = new Shape();
		var halfSize:uint = Math.round(size/2);
		child.graphics.beginFill(bgColor);
		child.graphics.lineStyle(borderSize, borderColor);
		child.graphics.drawCircle(halfSize, halfSize, halfSize);
		child.graphics.endFill();
		addChild(child);
		}
		
		private function doDrawRoundRect():void {
		var child:Shape = new Shape();
		child.graphics.beginFill(bgColor);
		child.graphics.lineStyle(borderSize, borderColor);
		child.graphics.drawRoundRect(0, 0, size, size, cornerRadius);
		child.graphics.endFill();
		addChild(child);
		}
		
		private function doDrawRect():void {
		var child:Shape = new Shape();
		child.graphics.beginFill(bgColor);
		child.graphics.lineStyle(borderSize, borderColor);
		child.graphics.drawRect(0, 0, size, size);
		child.graphics.endFill();
		addChild(child);
		}*/
	}
}