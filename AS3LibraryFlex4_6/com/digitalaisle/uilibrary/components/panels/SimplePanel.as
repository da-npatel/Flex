package com.digitalaisle.uilibrary.components.panels
{
	import com.digitalaisle.uilibrary.components.buttons.DASimpleButton;
	import com.digitalaisle.uilibrary.data.PanelObject;
	import com.digitalaisle.uilibrary.skins.SimplePanelSkin;
	import com.digitalaisle.uilibrary.supportClasses.PanelBase;
	
	import mx.events.FlexEvent;
	
	public class SimplePanel extends PanelBase
	{
		
		public function SimplePanel()
		{
			super();
			setStyle("skinClass", SimplePanelSkin);
		}
		
		override protected function applySettings(settingsObj:PanelObject):void
		{
			super.applySettings(settingsObj);
			
			upStateAsset = settingsObj.upStateAsset;
			downStateAsset = settingsObj.downStateAsset;
			disabledStateAsset = settingsObj.disabledStateAsset;
		}
		
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance)
			{
				case panelButton:
					panelButton.upStateAsset = upStateAsset;
					panelButton.downStateAsset = downStateAsset;

					break;
			}
		}
		
		override protected function onPanelAdded(e:FlexEvent):void
		{
			
		}
	

		override public function set downStateAsset(value:String):void
		{
			super.downStateAsset = value;
			if(panelButton)
				panelButton.downStateAsset = value;
		}

		override public function set upStateAsset(value:String):void
		{
			super.upStateAsset = value;
			if(panelButton)
				panelButton.upStateAsset = value;
		}

		override public function set disabledStateAsset(value:String):void
		{
			super.disabledStateAsset = value;
			if(panelButton)
				panelButton.disabledStateAsset = value;
		}
		
		/*override public function set settings(value:PanelObject):void
		{
			super.settings = value;
			
			if(panelButton)
			{
				panelButton.upStateAsset = settings.upStateAsset;
				panelButton.downStateAsset = settings.downStateAsset;
				panelButton.disabledStateAsset = settings.disabledStateAsset;
			}	
		}*/
		
		override public function get selected():Boolean
		{
			return panelButton.selected;
		}
		
		override public function set selected(value:Boolean):void
		{
			panelButton.selected = value;
		}
	}
}