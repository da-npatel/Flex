package com.digitalaisle.frontend.valueObjects.consultation
{
	public class QTextInputObject extends Object
	{
		public function QTextInputObject()
		{
			super();
		}
		//VARS
		public var type:int = 3;
		public var headerText:String;
		public var subheaderText:String;
		public var styleHeader:String = "h1";
		public var styleSubheader:String = "h2";
		
		//LAYOUT
		public var containerPaddingLeft:Number = 10;
		public var containerPaddingRight:Number = 10;
		public var containerPaddingTop:Number = 10;
		public var containerPaddingBottom:Number = 10;
		public var containerHeight:Number = 200;
		public var containerWidth:Number = 200;		
		public var containerHorizontalAlign:String = "center";
		public var containerVerticalAlign:String = "middle";
	}
}