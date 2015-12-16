package com.doer.common.tooltip
{
	import com.doer.resource.ResManager;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;
	
	public class ToolTip extends UIComponent
	{
		private var textField:TextField = null;
		
		public function ToolTip()
		{
			super();
			
			
		}
		
		
		/**
		 * 销毁资源
		 * **/
		public function onDestroy():void
		{
			removeChild(textField);
			textField = null;
		}
		
		/**
		 * 添加文字
		 * **/
		public function invalidateText(text:String):void
		{
			textField = new TextField();
			
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.text = text;
			
			var tft:TextFormat = new TextFormat();
			tft.size = 14;
			tft.font = "微软雅黑,Microsoft Yahei";
			tft.color = ResManager.getInstance().getColor("toolTipLabel");
			
			textField.setTextFormat(tft);
			
			this.width = textField.width + 16;
			this.height = textField.height + 16;
			
			textField.x = this.width/2 - textField.width/2;
			textField.y = this.height/2 - textField.height/2;
			
			addChild(textField);

			invalidateBackground();
		}
		
		/**
		 * 设置显示文字
		 * **/
		public function setText(text:String):void
		{
			textField.text = text;
			
			var tft:TextFormat = new TextFormat();
			tft.size = 14;
			tft.font = "微软雅黑,Microsoft Yahei";
			tft.color = ResManager.getInstance().getColor("toolTipLabel");
			
			textField.setTextFormat(tft);
		}
		
		/**
		 * 初始化背景
		 * **/
		private function invalidateBackground():void
		{
			this.graphics.clear();
			//this.graphics.lineStyle(0.5,ResManager.getInstance().getColor("toolTipBorder"));
			this.graphics.beginFill(ResManager.getInstance().getColor("toolTipBackground"));
			this.graphics.drawRoundRect(0,0,this.width,this.height,6,6);
			this.graphics.endFill();
			

		}
		
		
		
	}
}