select name, text
from  sysobjects  c_obj left join syscomments com on c_obj.id = com.id
where (c_obj.xtype     = 'P' or c_obj.xtype    = 'TR') and text like '%hai%'