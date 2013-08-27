#!/usr/bin/awk -f
BEGIN {
   #setup interval
   if (length(st) == 0) {
     st = "00:00"; 
   }
   if (length(et) == 0) {
     et = "24:00";   
   }

   service_count = 0;

   # info items
   time = 0;
   req_id = "-";

   # common info
   v = "-";
   service = "-";
   sec_id = "-";
   format = "-";
   partner = "-";
   elapse = 0;
   
   # exception info 
   exception = "-";
}

function sort(ARRAY, ELEMENTS, temp, i, j) {
        for (i = 2; i <= ELEMENTS; ++i) 
                for (j = i; ARRAY[j-1] > ARRAY[j]; --j) { 
                        temp = ARRAY[j]
                        ARRAY[j] = ARRAY[j-1]
                        ARRAY[j-1] = temp
        }
        return 
}

function print_stat_line(head, lead, len, val1, val2, i, tabs_stop) {
    tabs_stop = ""
    for (i = 0; i < len - length(head); i++) {
        tabs_stop = (tabs_stop ".");
    }
    
    print lead head tabs_stop val1 "\t\t" val2
}

function print_stat(item_array, stat_array, item_count, error_array, i, j) {
    for (i = 1; i <= item_count; i++) {
        myitem = item_array[i];

        if (length(stat_array[myitem, "Y"]) == 0) {
            stat_array[myitem, "Y"] = "0";
        }
        if (length(stat_array[myitem, "N"]) == 0) {
            stat_array[myitem, "N"] = "0";
        }

        print_stat_line(myitem, "", 50, stat_array[myitem, "Y"], stat_array[myitem, "N"])

        for (err in error_array) {
           if (match(err, ("^" myitem))) {
                print_stat_line(substr(err, length(myitem) + 2), "\t\t", 47, ("[" error_array[err] "]"))
           } 
        }

        stat_array["total", "Y"] += stat_array[myitem, "Y"];
        stat_array["total", "N"] += stat_array[myitem, "N"];
    }

    print "-------------------------------------------------------------------------"

    tabs_stop = ""
    for (i = 0; i < 50 - length("total"); i++) {
        tabs_stop = (tabs_stop ".");
    }
    print "total" tabs_stop stat_array["total", "Y"] "\t\t" stat_array["total", "N"]
}

/^20[0-9][0-9]/ { 
     # parse time
    split($2, timeelements, ":")

    hour = timeelements[1]
    minute = timeelements[2]
    time = (hour ":" minute)

    if ((time >= st) && (time < et)) {
        digest_line = $NF
        index_start = index(digest_line, "[") + 1;
        index_end = index(digest_line, "(");
        
        req_id = substr(digest_line, index_start, index_end - index_start);
        
        # parse common info

        digest_line = substr(digest_line, index_end + 1);
        index_end = index(digest_line, ")");
        
        invocation_line = substr(digest_line, 0, index_end - 1);
        split(invocation_line, common, ",");

        v = common[1];
        service = common[2];
        sec_id = common[3];
        format = common[4];
        partner = common[5];
        elapse = common[6];

        # parse business info
        
        digest_line = substr(digest_line, index_end + 2);
        index_end = index(digest_line, ")");
        
        # parse exception info
        
        digest_line = substr(digest_line, index_end + 2);
        index_end = index(digest_line, ")");
        exception = substr(digest_line, 0, index_end - 1);
        
        # calc statistics according to actions

        if (actions[service] != "Y") {
            service_count ++;
            actions_sort[service_count] = service;
            actions[service] = "Y";
        }
         
        if (exception == "-") {
            stat[service, "Y"] ++;
        } else {
            stat[service, "N"] ++;

            if (action_errors[(service "." exception)] == "") {
                action_errors[(service "." exception)] = 1;
            } else {
                action_errors[(service "." exception)] ++;
            } 
        }
    }
}

END {
    print "-------------------------------------------------------------------------"
    print " start time: " st "; end time: " et
    print "-------------------------------------------------------------------------"

    print "[actions]"

    sort(actions_sort, service_count);
    print_stat(actions_sort, stat, service_count, action_errors);
 }
