﻿create or replace package body lib_rep is

  -- LibORA PL/SQL Library
  -- http://bitbucket.org/rtfm/libora
  -- Author  : Taras Lyuklyanchuk
  -- Created : 15.05.2015 0:11:57
  -- Purpose : Simple Marker Report Engine

  function get_tags(p_templ clob) return t_list is
  
    list t_list := t_list();
    x    integer;
    y    integer;
    tag  varchar2(1000);
  begin
  
    x := 1;
    loop
    
      x := lib_lob.index_of(p_templ, OPEN_TAG, x);
    
      if (x > 0) then
      
        y := lib_lob.index_of(p_templ, CLOSE_TAG, x);
      
        if (y > 0) then
        
          tag := lib_lob.substring(p_templ, x, y);
        
          if tag not member of list then
            list.extend;
            list(list.last) := tag;
          end if;
        
          x := y;
        else
          x := -1;
        end if;
      end if;
    
      exit when nvl(x, 0) <= 0;
    end loop;
  
    return list;
  end;

  function get_xpath(p_tag varchar2) return varchar2 is
  
    xpath varchar2(4000);
  begin
  
    xpath := replace(replace(p_tag, OPEN_TAG), CLOSE_TAG);
  
    return replace(xpath, '.', '/');
  end;

  function get_data_map(p_tags t_list,
                        p_data xmltype) return types.HashMap is
  
    data types.HashMap;
  begin
  
    for i in 1 .. p_tags.count loop
      data(p_tags(i)) := lib_xml.getText(p_data, get_xpath(p_tags(i)));
    end loop;
  
    return data;
  end;

  function get_data_map$(p_tags t_list,
                         p_data xmltype) return types.ClobHashMap is
  
    data$ types.ClobHashMap;
  begin
  
    for i in 1 .. p_tags.count loop
      data$(p_tags(i)) := lib_xml.getText(p_data, get_xpath(p_tags(i)));
    end loop;
  
    return data$;
  end;

  function create_report(p_templ varchar2,
                         p_data  xmltype) return varchar2 is
  
    tags   t_list;
    data   types.HashMap;
    report varchar2(32767) := p_templ;
  begin
  
    tags := get_tags(p_templ);
    data := get_data_map(tags, p_data);
  
    for i in 1 .. tags.count loop
    
      if data.exists(tags(i)) then
        report := replace(report, tags(i), data(tags(i)));
      end if;
    end loop;
  
    return report;
  end;

  function create_report$(p_templ clob,
                          p_data  xmltype) return clob is
  
    tags   t_list;
    data$  types.ClobHashMap;
    report clob := p_templ;
  begin
  
    tags  := get_tags(p_templ);
    data$ := get_data_map$(tags, p_data);
  
    for i in 1 .. tags.count loop
    
      if data$.exists(tags(i)) then
        lib_lob.substitute(report, tags(i), data$(tags(i)));
      end if;
    end loop;
  
    return report;
  end;

end;
/

