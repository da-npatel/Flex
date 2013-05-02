package com.digitalaisle.uilibrary.components
{
	import com.digitalaisle.uilibrary.skins.ClearableTextInputSkin;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.TextInput;
	import spark.events.TextOperationEvent;
	
	public class ClearableTextInput extends TextInput 
	{
		
		/** Skin Parts **/
		[SkinPart(required="false")]
		public var clearButton:Button;
		
		public function ClearableTextInput() {
			super();
			
			//watch for programmatic changes to text property
			addEventListener(FlexEvent.VALUE_COMMIT, textChangedHandler, false, 0, true);
			
			//watch for user changes (aka typing) to text property
			addEventListener(TextOperationEvent.CHANGE, textChangedHandler, false, 0, true);
			setStyle("skinClass", ClearableTextInputSkin);
		}
		
		private function textChangedHandler(e:Event):void {
			if (clearButton)
				clearButton.visible = (text.length > 0);
		}
		
		private function clearClick(e:MouseEvent):void {
			text = "";
			dispatchEvent(new Event(Event.CLEAR));
		}
		
		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			if (instance == clearButton) {
				clearButton.addEventListener(MouseEvent.CLICK, clearClick);
				clearButton.visible = (text != null && text.length > 0);
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
			if (instance == clearButton) {
				clearButton.removeEventListener(MouseEvent.CLICK, clearClick);
			}
		}
	}

}