package com.digitalaisle.frontend.core.keypad.keys
{

	import com.digitalaisle.frontend.core.keypad.KeyFunctionType;
	import com.digitalaisle.frontend.core.keypad.skins.LetterKeySkin;
	import com.digitalaisle.frontend.valueObjects.KeyObject;
	
	import flash.events.Event;
	
	public class Letter extends Key
	{
		private var _isCaps:Boolean = true;
		
		public function Letter()
		{
			super();
			setStyle("skinClass", LetterKeySkin);
		}
		
		public function toggleCaps(isCaps:Boolean):void
		{
			if(functionType == KeyFunctionType.VALUE)
			{
				var letterValue:String = labelDisplay.text;
				
				if(isCaps)
				{
					letterValue = letterValue.toUpperCase();
				}else
				{
					letterValue = letterValue.toLowerCase();
				}
				
				labelDisplay.text = letterValue;
			}	
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(keyUpdated)
			{
				labelDisplay.text = value;
				
				keyUpdated = false;
			}
			
		}
		
		override public function set label(value:String):void
		{
			if(isCaps)
				value = value.toUpperCase();
			else
				value = value.toLowerCase();
			super.label = value;
		}

		
		public function get isCaps():Boolean
		{
			return _isCaps;
		}

		public function set isCaps(value:Boolean):void
		{
			_isCaps = value;
			toggleCaps(value);
		}


	}
}