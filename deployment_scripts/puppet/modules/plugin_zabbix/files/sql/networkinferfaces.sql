# No need for the 1st line as it is already present in the master DB file template data_clean.erb
# INSERT INTO `regexps` (`regexpid`, `name`, `test_string`) VALUES (2,'Network interfaces for discovery','eth0');
INSERT INTO `expressions` (`expressionid`,`regexpid`,`expression`,`expression_type`,`exp_delimiter`,`case_sensitive`) values (2,2,'^.*$',3,',',0);
