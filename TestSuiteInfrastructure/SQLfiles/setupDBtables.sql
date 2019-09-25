-- Creates entire thesis DB schema for MySQL.
-- All tables will be empty.

DROP TABLE testcases;
CREATE TABLE testcases (
	name    		VARCHAR(32),
    writeread       int,
    whichbound      int,
    datatype        int,
    memloc          int,
    scope           int,
    container       int,
    pointer         int,
    indexcomplex    int,
    addrcomplex     int,
    lencomplex      int,
    aliasaddr       int,
    aliasindex      int,
    localflow       int,
    secondaryflow   int,
    loopstructure   int,
    loopcomplex     int,
    asynchrony      int,
    taint           int,
    runtimeenvdep   int,
    continuousdiscrete  int,
    signedness      int
);

DROP TABLE archer;
CREATE TABLE archer (
	name    		VARCHAR(32),
    ok              int,
    min             int,
    med             int,
    large           int
);

DROP TABLE boon;
CREATE TABLE boon (
	name    		VARCHAR(32),
    ok              int,
    min             int,
    med             int,
    large           int
);

DROP TABLE polyspace;
CREATE TABLE polyspace (
	name    		VARCHAR(32),
    ok              int,
    min             int,
    med             int,
    large           int
);

DROP TABLE splint;
CREATE TABLE splint (
	name    		VARCHAR(32),
    ok              int,
    min             int,
    med             int,
    large           int
);

DROP TABLE uno;
CREATE TABLE uno (
	name    		VARCHAR(32),
    ok              int,
    min             int,
    med             int,
    large           int
);

LOAD DATA INFILE 'c:/Documents and Settings/Kendra Kratkiewicz/My Documents/Thesis/results/testcase_db_info.txt' INTO TABLE testcases;
LOAD DATA INFILE 'c:/Documents and Settings/Kendra Kratkiewicz/My Documents/Thesis/results/archer_db_info.txt' INTO TABLE archer IGNORE 1 lines;
LOAD DATA INFILE 'c:/Documents and Settings/Kendra Kratkiewicz/My Documents/Thesis/results/boon_db_info.txt' INTO TABLE boon IGNORE 1 lines;
LOAD DATA INFILE 'c:/Documents and Settings/Kendra Kratkiewicz/My Documents/Thesis/results/polyspace_db_info.txt' INTO TABLE polyspace IGNORE 1 lines;
LOAD DATA INFILE 'c:/Documents and Settings/Kendra Kratkiewicz/My Documents/Thesis/results/splint_db_info.txt' INTO TABLE splint IGNORE 1 lines;
LOAD DATA INFILE 'c:/Documents and Settings/Kendra Kratkiewicz/My Documents/Thesis/results/uno_db_info.txt' INTO TABLE uno IGNORE 1 lines;
