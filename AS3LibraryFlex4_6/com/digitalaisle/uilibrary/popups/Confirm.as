package com.digitalaisle.uilibrary.popups
{
	import com.digitalaisle.uilibrary.components.buttons.DASimpleButton;
	import com.digitalaisle.uilibrary.skins.ConfirmSkin;
	import com.digitalaisle.uilibrary.supportClasses.ContainerBase;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.ContainerGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.managers.IFocusManagerContainer;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import spark.components.Label;
	
	[Style(name="confirmLabelStyleName", type="String", inherit="yes")]
	[Style(name="yesButtonStyleName", type="String", inherit="yes")]
	[Style(name="noButtonStyleName", type="String", inherit="yes")]
	
	public class Confirm extends ContainerBase implements IFocusManagerContainer
	{
		/** Skin Parts **/
		[SkinPart(required="true")]
		public var confirmLabel:Label;
		[SkinPart(required="true")]
		public var yesButton:DASimpleButton;
		[SkinPart(required="true")]
		public var noButton:DASimpleButton;
		
		/** @private
		 *  Storage for the defaultButton property.
		 */
		private var _defaultButton:IFlexDisplayObject;
		private var _confirmed:Boolean;
		
		public function Confirm()
		{
			super();
			setStyle("skinClass", ConfirmSkin);
		}
		
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance)
			{
				case yesButton:
					try{
						if(getStyle("yesButtonStyleName"))
							yesButton.styleName = getStyle("yesButtonStyleName");
					}catch(errObject:Error){							
						MonsterDebugger.trace(this, "Warning: The following button style, " + getStyle("yesButtonStyleName") + ", is not available.  Please check the Style.css to make sure that the button style exists.", MonsterDebugger.COLOR_WARNING);
					}
					yesButton.addEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case noButton:
					try{
						if(getStyle("noButtonStyleName"))
							noButton.styleName = getStyle("noButtonStyleName");
					}catch(errObject:Error){
						MonsterDebugger.trace(this, "Warning: The following button style, " + getStyle("noButtonStyleName") + ", is not available.  Please check the Style.css to make sure that the button style exists.", MonsterDebugger.COLOR_WARNING);
					}
					noButton.addEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case confirmLabel:
					try{
						if(getStyle("confirmLabelStyleName"))
							confirmLabel.styleName = getStyle("confirmLabelStyleName");
					}catch(errObject:Error){
						MonsterDebugger.trace(this, "Warning: The following label style, " + getStyle("confirmLabelStyleName") + ", is not available.  Please check the Style.css to make sure that the button style exists.", MonsterDebugger.COLOR_WARNING);
					}
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			switch(instance)
			{
				case yesButton:
					yesButton.addEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case noButton:
					noButton.addEventListener(MouseEvent.CLICK, onButtonClick);
					break;
			}
		}
		
		
		protected function onButtonClick(e:MouseEvent):void
		{
			switch(e.currentTarget)
			{
				case yesButton:
					_confirmed = true;
					break;
				case noButton:
					_confirmed = false;
					break;
			}
			dispatchEvent(new Event(Event.SELECT));
		}
		
		public function get confirmed():Boolean
		{
			return _confirmed;
		}
		
		/**
		 *  The Button control designated as the default button for the container.
		 *  When controls in the container have focus, pressing the
		 *  Enter key is the same as clicking this Button control.
		 *
		 *  @default null
		 */
		override public function get defaultButton():IFlexDisplayObject
		{
			return _defaultButton;
		}
		
		/**
		 *  @private
		 */
		override public function set defaultButton(value:IFlexDisplayObject):void
		{
			_defaultButton = value;
			ContainerGlobals.focusedContainer = null;
		}
	}
}