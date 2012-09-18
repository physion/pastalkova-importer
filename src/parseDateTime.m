function d = parseDateTime(dateString, timezoneString)
   
    import org.joda.time.DateTime;
	import org.joda.time.DateTimeZone;
    
    if strcmp(timezoneString, 'ET')
        timezoneString = 'America/New_York';
    end
    
    timezone = DateTimeZone.forID(timezoneString);
    
    d = DateTime(dateString, timezone);
end