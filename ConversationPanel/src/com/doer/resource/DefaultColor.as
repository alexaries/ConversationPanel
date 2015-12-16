package com.doer.resource
{
	import flash.utils.ByteArray;
	import flash.xml.XMLDocument;

	public class DefaultColor
	{
		
		
		[Embed(source="assets/color/color.xml",mimeType="application/octet-stream")]
		private var colorXmlClass:Class;
		
		private var colorXml:XML = null;
		
		public function DefaultColor()
		{
			var byteDataXml:ByteArray = new colorXmlClass();  
			colorXml = XML(byteDataXml.readUTFBytes(byteDataXml.bytesAvailable)); 
			
		}
		
		public function getColorByName(name:String):uint
		{
			var xmlList:XMLList = colorXml[name];
			
			if(xmlList.length() == 0)
				return colorXml['defaultColor'];
			
			return colorXml[name];
		}
		
		
	}
}