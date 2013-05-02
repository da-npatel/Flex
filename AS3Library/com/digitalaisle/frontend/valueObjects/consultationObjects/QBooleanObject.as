package com.digitalaisle.frontend.valueObjects.consultationObjects
{
	import mx.collections.ArrayCollection;

	public class QBooleanObject extends Object
	{
		public function QBooleanObject()
		{
			super();
		}
		//CONST TYPE
		public var type:int = 2;
		
		//ASSETS
		public var headerText:String;
		public var subheaderText:String;

		//VARS	
		public var selectedValue:Boolean;
		public var falseValue:ArrayCollection;
		public var trueValue:ArrayCollection;
		
		//STYLES
		public var styleHeader:String = "h1";
		public var styleSubheader:String = "h2";
		public var styleNameDown:String;
		public var styleNameDisabled:String;
		public var styleNameIdle:String;		
		
		//BUTTON IMAGE LINKS
		public var buttonTrueIdle:String;
		public var buttonTrueDown:String;
		public var buttonTrueDisabled:String;		
		public var buttonFalseIdle:String;
		public var buttonFalseDown:String;
		public var buttonFalseDisabled:String;
		
		//LAYOUT
		public var layoutObj:LayoutObject;
		/*public var buttonGap:Number = 20;	
		public var containerPaddingLeft:Number = 10;
		public var containerPaddingRight:Number = 10;
		public var containerPaddingTop:Number = 10;
		public var containerPaddingBottom:Number = 10;
		public var containerHeight:Number = 200;
		public var containerWidth:Number = 200;		
		public var containerHorizontalAlign:String = "center";
		public var containerVerticalAlign:String = "middle";*/
		
	}
}