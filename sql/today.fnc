﻿create or replace function today return date is
begin
  
  -- Returns today date without time
  -- LibORA PL/SQL Library
  -- (c) 1981-2014 Taras Lyuklyanchuk 

  return trunc(sysdate);
end;
/

