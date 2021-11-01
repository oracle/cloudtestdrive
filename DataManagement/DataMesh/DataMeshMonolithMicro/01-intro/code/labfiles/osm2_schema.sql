
drop user osm2 cascade
/


create user osm2 identified by "Welcome12----";
/

alter user osm2 default tablespace users
               quota unlimited on users;
/
grant create session, resource to osm2;
/

CREATE OR REPLACE EDITIONABLE PROCEDURE "OSM2"."CALLOUT_MS" (p_dm_domain varchar2,
                                        p_cust_no   varchar2,
                                        p_pol_no    varchar2,
                                        p_pol_from  varchar2,
                                        p_pol_to    varchar2,
                                        p_pol_value varchar2,
                                        p_pol_sub_total varchar2,
                                        p_pol_total     varchar2) is  
    l_req_body clob;  
    l_resp     clob;
begin    
    apex_web_service.g_request_headers(1).name := 'Content-Type';  
    apex_web_service.g_request_headers(1).value := 'application/json';
    apex_web_service.g_request_headers(2).name := 'user-agent';  
    apex_web_service.g_request_headers(2).value := 'mozilla/4.0';
      --create the JSON request body  
    apex_json.initialize_clob_output();  
    apex_json.open_object();  
    apex_json.write('cust_no', p_cust_no);  
    apex_json.write('pol_no', p_pol_no);  
    apex_json.write('pol_from', p_pol_from);  
    apex_json.write('pol_to', p_pol_to);  
    apex_json.write('pol_value', p_pol_value);  
    apex_json.write('pol_sub_total', p_pol_sub_total);  
    apex_json.write('pol_total', p_pol_total);  
    apex_json.close_all();  
    l_req_body := apex_json.get_clob_output();  
    apex_json.free_output();  
    dbms_output.put_line('l_req_body=' || l_req_body);  
    l_resp := apex_web_service.make_rest_request(  
        p_url => 'https://<your_API_Gateway_Hostname>/ms/' || p_dm_domain,  
        p_http_method => 'PUT',
        p_body => l_req_body
        );  
    -- Display the whole document returned.  
    dbms_output.put_line('l_clob=' || l_resp);
end callout_ms;
/

grant execute on osm2.callout_ms to ggadmin

-- To test the procedure for debugging purposes : 
-- exec callout_ms('med','jj','kk','mm','cc','ll','uu','nn')