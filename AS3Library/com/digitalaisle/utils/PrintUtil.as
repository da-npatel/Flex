package com.digitalaisle.utils
{
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	
	import mx.core.IUIComponent;
	import mx.printing.FlexPrintJob;
	import mx.printing.FlexPrintJobScaleType;
	
	import spark.utils.BitmapUtil;
	
	public class PrintUtil
	{
		
		public function PrintUtil()
		{
			
		}
		
		// Create a PrintJob.
		public static function doPrint(iuic:IUIComponent, printJobOptions:PrintJobOptions = null):void {

			var printJob:FlexPrintJob = new FlexPrintJob();
			if(printJob.start())
			{
				printJob.addObject(iuic, FlexPrintJobScaleType.NONE);
				printJob.send();
			}
			
		}
		
		//this method accepts an array of uicomponents and another array of printJobOptions, that correlate with each other.
		public static function doMultiPrint(iuicArray:Array, printJobOptionsArray:Array = null):void {
			for(var i:int = 0; i < iuicArray.length; i++){
				try{
					var pj:PrintJob = new PrintJob();
					var bmd:BitmapData = BitmapUtil.getSnapshot(iuicArray[i]);
					var bm:Bitmap = new Bitmap(bmd, "auto", true);
					
					var pjoNode:PrintJobOptions = null;
					if(printJobOptionsArray[i] != null){
						pjoNode = printJobOptionsArray[i] as PrintJobOptions;
					}
				}catch(e:Error){
					trace("those arrays should be full of iuic's and printJobOptions respectively, they prob aren't");
					trace(e.message);
				}
				var containerSprite:Sprite = new Sprite();
				containerSprite.addChild(bm);
				pj.addPage(containerSprite, null, pjoNode);
			}
			
			pj.send();
		}
	}
	
}