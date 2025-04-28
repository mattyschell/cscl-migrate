select 
    distinct table_name 
from 
    user_tab_columns
where 
    not REGEXP_LIKE(table_name, '^[DFS][0-9]+$')
    and table_name not like 'KEYSET%'
    and table_name not like 'SDE%'
    and table_name not like 'T_1%'
minus
select 
    table_name 
from 
    user_tab_columns 
where 
    column_name = 'GLOBALID';