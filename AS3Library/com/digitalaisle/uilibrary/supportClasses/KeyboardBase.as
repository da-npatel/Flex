package com.digitalaisle.uilibrary.supportClasses
{
	import com.digitalaisle.frontend.core.keypad.KeyFunctionType;
	import com.digitalaisle.frontend.events.DAKeyboardEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.TextInput;

	public class KeyboardBase extends ContainerBase
	{
		/** Skin Parts **/
		[SkinPart(required="false")]
		public var inputField:TextInput;
		[SkinPart(required="false")]
		public var doneButton:Button;
		
		private var _inputValue:String = "";
		
		private var _isCaps:Boolean = true;
		private var _maxChars:int;
		
		public function KeyboardBase()
		{
			super();
			addEventListener(DAKeyboardEvent.KEY_PRESSED, onKeyPress);
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance)
			{
				case doneButton:
					doneButton.addEventListener(MouseEvent.CLICK, onDoneClick);
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			switch(instance)
			{
				case doneButton:
					doneButton.removeEventListener(MouseEvent.CLICK, onDoneClick);
					break;
			}
		}
		
		
		protected function updateKeyboardInput(value:String):void
		{
			if(isCaps)
				value = value.toUpperCase();
			else
				value = value.toLowerCase();
			
			inputValue += value;
			if(inputField)
				inputField.text = inputValue;
			
		}
		
		protected function clearKeyboardInput():void
		{
			inputValue = ""
			if(inputField)
				inputField.text = inputValue;
		}
		
		private function deletePreviousInputValue():void
		{
			if(inputValue.length > 0)
			{
				var preCharLength:Number = (inputValue.length - 1);
				inputValue = inputValue.slice(0, preCharLength);
				//TODO: Should this line be within setter of inputValue
				if(inputField)
					inputField.text = inputValue;
			}
		}
		
		protected function toggleKeyboardLayouts():void { }
		
		protected function done():void
		{
			if(inputField)
				inputField.text = inputValue;
		}
		
		protected function onKeyPress(e:DAKeyboardEvent):void
		{
			var keyValue:String = e.target.label;
			
			switch(e.keyFunction)
			{
				case KeyFunctionType.VALUE:
					updateKeyboardInput(keyValue);
					break;
				case KeyFunctionType.CAP:
					isCaps = !isCaps;
					break;
				case KeyFunctionType.SPACE:
					updateKeyboardInput(" ");
					break;
				case KeyFunctionType.CLEAR:
					clearKeyboardInput();
					break;
				case KeyFunctionType.DELETE:
					deletePreviousInputValue();
					break;
				case KeyFunctionType.TOGGLE:
					toggleKeyboardLayouts();
					break;
				case KeyFunctionType.COM:
					inputValue += keyValue;
					if(inputField)
						inputField.text = inputValue;
					break;
			}
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		
		protected function onCreationComplete(e:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		private function onDoneClick(e:MouseEvent):void
		{
			done();
		}
		
		[Bindable]
		public function get inputValue():String
		{
			return _inputValue;
		}
		
		public function set inputValue(value:String):void 
		{
			_inputValue = value;
		}

		[Bindable]
		public function get isCaps():Boolean
		{
			return _isCaps;
		}

		public function set isCaps(value:Boolean):void
		{
			_isCaps = value;
		}

	}
}