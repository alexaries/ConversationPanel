package com.doer.modes.courseware.mode
{
	public class CoursewarePaintData
	{
		/**
		 * 绑定的课件id
		 * **/
		public var bookId:String = null;
		
		/**
		 * 绑定的课件页
		 * **/
		public var pageId:int = 0;
		
		/**
		 * 绑定的绘图数据
		 * **/
		public var paintDatas:Array = null;
		
		public function CoursewarePaintData(bookId:String,pageId:int)
		{
			this.bookId = bookId;
			this.pageId = pageId;
			
			this.paintDatas = new Array();
			
		}
		
		/**
		 * 添加绘图数据
		 * **/
		public function addPaintData(data:Object):void
		{
			paintDatas.push(data);	
		}
		
	}
}