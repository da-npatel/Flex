package com.digitalaisle.themeLibrary.types
{
	import flash.utils.getDefinitionByName;

	public class ModuleSkinType
	{
		public static const ABOUT_US_DEFAULT:String = "aboutUsDefault";
		public static const CALENDAR_DEFUALT:String = "calendarDefault";
		public static const CONSULTATION_DEFUALT:String = "consultationDefault";
		public static const SINGLE_ITEM_FINDER:String = "singleItemFinder";
		public static const MULTI_ITEM_FINDER:String = "multiItemFinder";
		public static const DUAL_ITEM_FINDER:String = "dualItemFinder";
		public static const PARTY_PLANNER_DEFAULT:String = "partyPlannerDefault";
		public static const AGE_GATE_DEFAULT:String = "ageGateDefault";
		public static const AVATAR_MAKER_DEFAULT:String = "avatarMaker";
		
		public function ModuleSkinType()
		{
		}
		
		// Creates the targeted module skin class by its type
		/*public static function createInstanceByType(type:String):Class
		{
			var instance:Class;
			
			switch(type)
			{
				case ABOUT_US_DEFAULT:
					//instance = getDefinitionByName() as Class;
					break;
				case CALENDAR_DEFUALT:
					
					break;
				case CONSULTATION_DEFUALT:
					
					break;
				case SINGLE_ITEM_FINDER:
					
					break;
				case MULTI_ITEM_FINDER:
					
					break;
			}
		}*/
	}
}