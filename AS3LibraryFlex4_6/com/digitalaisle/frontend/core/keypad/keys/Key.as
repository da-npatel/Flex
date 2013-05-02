package com.digitalaisle.frontend.core.keypad.keys
{
	import com.digitalaisle.frontend.events.DAKeyboardEvent;
	import com.digitalaisle.frontend.valueObjects.KeyObject;
	import com.digitalaisle.uilibrary.components.buttons.DAButton;
	
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	public class Key extends DAButton
	{
		public var keySound:Sound;
	
		protected var type:int;
		protected var value:String;
		protected var weight:int;
		public var functionType:String;
		protected var soundChannel:SoundChannel = new SoundChannel();
		protected var keyUpdated:Boolean = false;
		
		public function Key()
		{
			// NEEDS TO BE BUILT OUT:  What does the base class need to support
			
			// TODO: attach sound via Mouse Down...Double check to see if mouse down is supported via touch screen
			// TODO: assignValue();	input and visual value
			// 
			super();
			addEventListener(MouseEvent.MOUSE_DOWN, onKeyClick);
		}
		
		public function assignKeyObject(obj:KeyObject):void
		{
			type = obj.type;
			value = obj.value;
			weight = obj.weight;
			functionType = obj.functionType;
			

			keyUpdated = true;
		}
		
		public function destroy():void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, onKeyClick);
		}
		
		protected function onKeyClick(e:MouseEvent):void
		{
			// play sound
			//soundChannel = keySound.play();
			
			dispatchEvent(new DAKeyboardEvent(DAKeyboardEvent.KEY_PRESSED, functionType, value, true));
		}
		
		
	}
}