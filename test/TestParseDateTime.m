% Copyright (c) 2012 Physion Consulting LLC

classdef TestParseDateTime < TestMatlabSuite
    
    properties
    end
    
    methods
        
        function self = TestParseDateTime(name)
             self = self@TestMatlabSuite(name);
        end 
        
        function testShouldParseFixtureExperimentDate(~)
            import ovation.*;
            
            datestr = '2012-03-18';
            timezone = 'ET';
            
            d = parseDateTime(datestr, timezone);
            
            assertTrue(d.equals(ovation.datetime(2012, 03, 18, 0, 0, 0, 0, 'America/New_York')));
        end
    end
end