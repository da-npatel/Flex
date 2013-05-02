package com.digitalaisle.frontend.valueObjects.consultationObjects
{
	public class LayoutObject extends Object
	{
		public var layout:String = "vertical";  // HORIZONTAL OR VERTICAL - custom
		
		public var horizontalAlign:String = "left";
		public var verticalAlign:String = "top";
		
		public var paddingTop:Number = 0;
		public var paddingBottom:Number = 0;
		public var paddingRight:Number = 0;
		public var paddingLeft:Number = 0;
		
		public var top:Number = 0;
		public var bottom:Number = 0;
		public var right:Number = 0;
		public var left:Number = 0;
		
		public var gap:Number = 0;
		
		public var width:Number = 0;
		public var percentWidth:Number = 0;
		public var height:Number = 0;
		public var percentHeight:Number = 0;
		
		public var tilesColumnCount:Number = 0;
		public var tilesRowCount:Number = 0;
		public var tilesColumnWidth:Number = 0;
		public var tilesRowHeight:Number = 0;
		
		public var x:Number = 0;
		public var y:Number = 0;
		
		public function LayoutObject()
		{
			super();
		}
	}
}