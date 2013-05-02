package com.digitalaisle.uilibrary.supportClasses
{
	import com.digitalaisle.uilibrary.components.buttons.DASimpleButton;
	import com.digitalaisle.uilibrary.data.PanelObject;
	
	import mx.events.FlexEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.RichText;
	import spark.components.supportClasses.SkinnableComponent;
	
	[Style(name="labelStyleName", type="String", inherit="yes")]
	
	[Style(name="richTextStyleName", type="String", inherit="yes")]
	
	public class PanelBase extends SkinnableComponent
	{
		[SkinPart(required="true")]
		public var panelButton:DASimpleButton;
		[SkinPart(required="false")]
		public var labelDisplay:Label;
		[SkinPart(required="false")]
		public var richTextDisplay:RichText;
		[SkinPart(required="false")]
		public var productImage:Image;
		
		public var index:int = 0;
		private var _settings:PanelObject;
		private var _labelText:String;
		private var _descriptionText:String;
		private var _labelTextStyle:String;
		private var _descriptionTextStyle:String;
		private var _buttonStyleName:String;
		private var _imageSource:String;
		
		private var _downStateAsset:String;
		private var _upStateAsset:String;
		private var _disabledStateAsset:String;
		
		public function PanelBase()
		{
			super();
			addEventListener(FlexEvent.REMOVE, onPanelRemoved);
			addEventListener(FlexEvent.ADD, onPanelAdded);
		}
		
		

		protected function applySettings(settingsObj:PanelObject):void
		{
			uid = settingsObj.uid;
			labelText = settingsObj.labelText;
			descriptionText = settingsObj.descriptionText;
			buttonStyleName = settingsObj.buttonStyleName;
			imageSource=settingsObj.imageurl;
		}

		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance)
			{
				case panelButton:
					if(buttonStyleName)
					{
						try{
							panelButton.styleName = buttonStyleName;
						}catch(errorObject:Error){
							// Warning needed
						}
					}
					break;
				case labelDisplay:
					if(getStyle("labelStyleName"))
						verifyPopulateStyleName(labelDisplay, getStyle("labelStyleName"));
					labelDisplay.mouseEnabled = false;
					labelDisplay.text = labelText; //NOTE: Use styles for the styling.
					break;
				case richTextDisplay:
					if(getStyle("richTextStyleName"))
						verifyPopulateStyleName(richTextDisplay, getStyle("richTextStyleName"));
					richTextDisplay.mouseEnabled  = false;
					richTextDisplay.text = descriptionText;
					break;
				case productImage:
					if(imageSource!=null)
					productImage.source=imageSource;
					break;
			}
		}
		
		private function verifyPopulateStyleName(instance:Object, styleName:Object):void
		{
			if(styleName)
			{
				try{
					instance.styleName = styleName;
				}catch(errorObject:Error){
					MonsterDebugger.trace(this, "Warning: The following style, " + getStyle("sendButtonStyleName") + " , does not exist.  Please double check the spelling and/or existence of this style name.", MonsterDebugger.COLOR_WARNING);
				}
			}
		}
		
		protected function onPanelRemoved(e:FlexEvent):void
		{
			removeEventListener(FlexEvent.REMOVE, onPanelRemoved);
			removeEventListener(FlexEvent.ADD, onPanelAdded);
		}
		
		protected function onPanelAdded(e:FlexEvent):void
		{
			
		}
		public function get imageSource():String
		{
			return _imageSource;
		}
		
		public function set imageSource(value:String):void
		{
			_imageSource = value;
			if(productImage)
				productImage.source= imageSource;
		}
		public function get labelText():String
		{
			return _labelText;
		}

		public function set labelText(value:String):void
		{
			_labelText = value;
			if(labelDisplay)
				labelDisplay.text = _labelText;
		}

		public function get descriptionText():String
		{
			return _descriptionText;
		}

		public function set descriptionText(value:String):void
		{
			_descriptionText = value;
			if(richTextDisplay)
				richTextDisplay.text = _descriptionText;
		}

		public function get labelTextStyle():String
		{
			return _labelTextStyle;
		}

		public function set labelTextStyle(value:String):void
		{
			_labelTextStyle = value;
			if(labelDisplay)
				labelDisplay.styleName = _labelTextStyle;
		}

		public function get descriptionTextStyle():String
		{
			return _descriptionTextStyle;
		}

		public function set descriptionTextStyle(value:String):void
		{
			_descriptionTextStyle = value;
			if(richTextDisplay)
				richTextDisplay.styleName = _descriptionTextStyle;
		}

		public function get settings():PanelObject
		{
			return _settings;
		}

		public function set settings(value:PanelObject):void
		{
			if(_settings == value)
				return;
			_settings = value;
			applySettings(_settings);
		}
		
		public function get selected():Boolean
		{
			if(panelButton)
				return panelButton.selected;
			else
				return false;
		}
		
		public function set selected(value:Boolean):void 
		{
			if(panelButton)
				panelButton.selected = value;
		}

		public function get buttonStyleName():String
		{
			return _buttonStyleName;
		}
		
		public function set buttonStyleName(value:String):void
		{
			if(buttonStyleName == value)
				return;
			_buttonStyleName = value;
			if(panelButton)
				panelButton.styleName = value;
		}
		
		public function get downStateAsset():String
		{
			return _downStateAsset;
		}
		
		public function set downStateAsset(value:String):void
		{
			_downStateAsset = value;
		}
		
		public function get upStateAsset():String
		{
			return _upStateAsset;
		}
		
		public function set upStateAsset(value:String):void
		{
			_upStateAsset = value;
		}
		
		public function get disabledStateAsset():String
		{
			return _disabledStateAsset;
		}
		
		public function set disabledStateAsset(value:String):void
		{
			_disabledStateAsset = value;
		}
	}
}