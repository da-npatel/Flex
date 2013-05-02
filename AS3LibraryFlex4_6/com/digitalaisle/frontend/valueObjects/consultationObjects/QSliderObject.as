package com.digitalaisle.frontend.valueObjects.consultationObjects
{
	import mx.collections.ArrayCollection;
	
	public class QSliderObject extends QuestionObject
	{
		public function QSliderObject()
		{
			super();
		}
		//VARS
		public var selectedValue:Number;		
		public var styleHeader:String = "h1";
		public var styleSubheader:String = "h2";
		public var styleSmallValueLabel:String = "h2";
		public var sliderHandleImage:String;
		public var sliderBarImage:String;
		public var sliderDataProvider:ArrayCollection;
		
		//LAYOUT
		public var layoutObj:LayoutObject;
		/*public var containerPaddingLeft:Number = 10;
		public var containerPaddingRight:Number = 10;
		public var containerPaddingTop:Number = 10;
		public var containerPaddingBottom:Number = 10;
		public var containerHeight:Number = 200;
		public var containerWidth:Number = 200;		
		public var containerHorizontalAlign:String = "center";
		public var containerVerticalAlign:String = "middle";*/
	}
}