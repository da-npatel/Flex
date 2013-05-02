package com.digitalaisle.uilibrary.projectContent
{
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	
	import org.casalib.util.ObjectUtil;
	
	public class ProjectRecipeItem extends ProjectContentItem
	{
		public var ingredients:Vector.<Ingredient> = new Vector.<Ingredient>();
		
		public function ProjectRecipeItem()
		{
			super();
		}
		
		override public function create(projectRecipeItemNode:XML, uri:String, ownerId:int, projectURI:String):void
		{
			super.create(projectRecipeItemNode, uri, ownerId, projectURI);
			
			for(var i:int = 0; i < relatedItems.length; i++)
			{
				var ingredient:Ingredient = new Ingredient();
				ingredient.id = relatedItems[i].relatedItemId;
				ingredient.quantity = relatedItems[i].relationData.hasOwnProperty("Quantity") ? relatedItems[i].relationData.Quantity : 0;
				ingredient.uom = relatedItems[i].relationData.hasOwnProperty("UoM") ? relatedItems[i].relationData.UoM : "";
				ingredients.push(ingredient);
			}
		}
	}
}