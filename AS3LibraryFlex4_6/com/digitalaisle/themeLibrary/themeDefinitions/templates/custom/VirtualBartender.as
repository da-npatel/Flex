package com.digitalaisle.themeLibrary.themeDefinitions.templates.custom
{
	import com.digitalaisle.themeLibrary.base.TemplateSkinBase;
	import com.digitalaisle.themeLibrary.types.AssetSkinType;
	import com.digitalaisle.themeLibrary.types.ModuleSkinType;
	import com.digitalaisle.themeLibrary.types.TemplateSkinType;
	
	public class VirtualBartender extends TemplateSkinBase
	{
		public function VirtualBartender()
		{
			super();
			
			//id = "";
			type = TemplateSkinType.VB_AVATAR_HALF;
			templateSWFRef = "";		// Later on this can be dictated by resolution???
			supportedModules = [ModuleSkinType.CONSULTATION_DEFUALT, ModuleSkinType.SINGLE_ITEM_FINDER, ModuleSkinType.AGE_GATE_DEFAULT, ModuleSkinType.PARTY_PLANNER_DEFAULT];
			supportedAssets = [AssetSkinType.TEMPLATE_STYLE_SWF, AssetSkinType.DEFAULT_MODULE_BKGD, AssetSkinType.FOOTER_BKGD, AssetSkinType.PREV_NAV_IDLE, AssetSkinType.PREV_NAV_DOWN, AssetSkinType.NEXT_NAV_IDLE, AssetSkinType.NEXT_NAV_DOWN, AssetSkinType.CONFIRM_BKGD, AssetSkinType.CONFIRM_BTN_NO_IDLE, AssetSkinType.CONFIRM_BTN_NO_DOWN,AssetSkinType.CONFIRM_BTN_YES_IDLE,AssetSkinType.CONFIRM_BTN_YES_DOWN];
		
		}
	}
}