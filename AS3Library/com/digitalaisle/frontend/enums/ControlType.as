package com.digitalaisle.frontend.enums
{
	import com.adobe.utils.ArrayUtil;

	public final class ControlType
	{
		public static const LOGO:int = 0;
		public static const BACKGROUND:int = 1;
		public static const SIDEBAR_ADVERT:int = 2;
		public static const CORE_MODULE:int = 3;
		public static const PANELSLIDER:int = 4;
		public static const AVATAR_VIDEOPLAYER:int = 5;
		public static const STANDARD_VIDEOPLAYER:int = 6;
		public static const ITEM_FINDER:int = 7;
		public static const ABOUT_US:int = 8;
		public static const GENERIC_WIDGET:int = 9;
		public static const CONSULTATION:int = 10;
		public static const MULTIPLE_CHOICE_QUESTION:int = 11
		public static const SINGLE_CHOICE_QUESTION:int = 12;
		public static const VALUE_SLIDER_QUESTION:int = 13;
		public static const ANSWER:int = 14;
		public static const CALENDAR:int = 15;
		public static const CATEGORY:int = 16;
		public static const PRODUCTS:int = 17;
		public static const PRODUCT_ITEM:int = 18;
		public static const EXTERNAL_MODULE:int = 19;
		public static const EXTERNAL_PORTAL:int = 20;
		public static const THEME_SCHEMA:int = 21;
		public static const TICKER:int = 22;
		public static const MULTI_ITEM_FINDER:int = 23;
		public static const PROMO_ITEM:int = 24;
		public static const PROJECT_AVATAR:int = 25;
		public static const CONTENT_ITEM:int = 26;
		
		public static const SEARCH:int = 27;
		public static const RECIPE_ITEM:int = 28;
		public static const AVATAR_MAKER:int = 29;
		public static const AVATAR_SPORT:int = 30;
		public static const AVATAR_BODY_FEATURE:int = 30;
		public static const AVATAR_GENDER:int = 32;
		public static const AVATAR_CLOTHING:int = 33;
		public static const AVATAR_ACCESSORIES:int = 34;
		public static const AVATAR_STYLE:int = 35;
		public static const AVATAR_ITEM:int = 36;
		public static const AVATAR_ITEM_TYPE:int = 37;
		public static const PROJECT_ASSETS:int = 38;
		public static const WEATHER_MODULE:int = 39;
		public static const ONE_SOURCE:int = 40;
		public static const PCI_VISUALIZER:int = 41;
		public static const COUPON_ITEM:int = 42;
		public static const QR_CODE:int = 43;
		public static const RANK_QUESTION:int = 44;
		public static const FREE_TEXT_QUESTION:int = 45;
		
		public function ControlType()
		{
		}
		
		public static function isItem(controlType:int):Boolean
		{
			var itemControltypes:Array = [ControlType.PRODUCT_ITEM, ControlType.CONTENT_ITEM, ControlType.RECIPE_ITEM, ControlType.CALENDAR];
			if(ArrayUtil.arrayContainsValue(itemControltypes, controlType))
				return true;
			else
				return false;
		}
	}
}