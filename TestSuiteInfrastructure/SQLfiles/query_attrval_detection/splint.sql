use thesis;

select count(*) from testcases where writeread=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.writeread=0 and S.min=1;
select count(*) from testcases where writeread=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.writeread=1 and S.min=1;

select count(*) from testcases where whichbound=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.whichbound=0 and S.min=1;
select count(*) from testcases where whichbound=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.whichbound=1 and S.min=1;

select count(*) from testcases where datatype=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.datatype=0 and S.min=1;
select count(*) from testcases where datatype=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.datatype=1 and S.min=1;
select count(*) from testcases where datatype=2;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.datatype=2 and S.min=1;
select count(*) from testcases where datatype=3;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.datatype=3 and S.min=1;
select count(*) from testcases where datatype=4;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.datatype=4 and S.min=1;
select count(*) from testcases where datatype=5;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.datatype=5 and S.min=1;
select count(*) from testcases where datatype=6;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.datatype=6 and S.min=1;

select count(*) from testcases where memloc=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.memloc=0 and S.min=1;
select count(*) from testcases where memloc=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.memloc=1 and S.min=1;
select count(*) from testcases where memloc=2;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.memloc=2 and S.min=1;
select count(*) from testcases where memloc=3;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.memloc=3 and S.min=1;
select count(*) from testcases where memloc=4;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.memloc=4 and S.min=1;

select count(*) from testcases where scope=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.scope=0 and S.min=1;
select count(*) from testcases where scope=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.scope=1 and S.min=1;
select count(*) from testcases where scope=2;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.scope=2 and S.min=1;
select count(*) from testcases where scope=3;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.scope=3 and S.min=1;

select count(*) from testcases where container=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.container=0 and S.min=1;
select count(*) from testcases where container=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.container=1 and S.min=1;
select count(*) from testcases where container=2;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.container=2 and S.min=1;
select count(*) from testcases where container=3;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.container=3 and S.min=1;
select count(*) from testcases where container=4;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.container=4 and S.min=1;
select count(*) from testcases where container=5;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.container=5 and S.min=1;

select count(*) from testcases where pointer=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.pointer=0 and S.min=1;
select count(*) from testcases where pointer=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.pointer=1 and S.min=1;

select count(*) from testcases where indexcomplex=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.indexcomplex=0 and S.min=1;
select count(*) from testcases where indexcomplex=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.indexcomplex=1 and S.min=1;
select count(*) from testcases where indexcomplex=2;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.indexcomplex=2 and S.min=1;
select count(*) from testcases where indexcomplex=3;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.indexcomplex=3 and S.min=1;
select count(*) from testcases where indexcomplex=4;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.indexcomplex=4 and S.min=1;
select count(*) from testcases where indexcomplex=5;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.indexcomplex=5 and S.min=1;
select count(*) from testcases where indexcomplex=6;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.indexcomplex=6 and S.min=1;

select count(*) from testcases where addrcomplex=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.addrcomplex=0 and S.min=1;
select count(*) from testcases where addrcomplex=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.addrcomplex=1 and S.min=1;
select count(*) from testcases where addrcomplex=2;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.addrcomplex=2 and S.min=1;
select count(*) from testcases where addrcomplex=3;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.addrcomplex=3 and S.min=1;
select count(*) from testcases where addrcomplex=4;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.addrcomplex=4 and S.min=1;
select count(*) from testcases where addrcomplex=5;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.addrcomplex=5 and S.min=1;

select count(*) from testcases where lencomplex=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.lencomplex=0 and S.min=1;
select count(*) from testcases where lencomplex=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.lencomplex=1 and S.min=1;
select count(*) from testcases where lencomplex=2;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.lencomplex=2 and S.min=1;
select count(*) from testcases where lencomplex=3;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.lencomplex=3 and S.min=1;
select count(*) from testcases where lencomplex=4;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.lencomplex=4 and S.min=1;
select count(*) from testcases where lencomplex=5;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.lencomplex=5 and S.min=1;
select count(*) from testcases where lencomplex=6;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.lencomplex=6 and S.min=1;
select count(*) from testcases where lencomplex=7;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.lencomplex=7 and S.min=1;

select count(*) from testcases where aliasaddr=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.aliasaddr=0 and S.min=1;
select count(*) from testcases where aliasaddr=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.aliasaddr=1 and S.min=1;
select count(*) from testcases where aliasaddr=2;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.aliasaddr=2 and S.min=1;

select count(*) from testcases where aliasindex=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.aliasindex=0 and S.min=1;
select count(*) from testcases where aliasindex=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.aliasindex=1 and S.min=1;
select count(*) from testcases where aliasindex=2;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.aliasindex=2 and S.min=1;
select count(*) from testcases where aliasindex=3;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.aliasindex=3 and S.min=1;

select count(*) from testcases where localflow=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.localflow=0 and S.min=1;
select count(*) from testcases where localflow=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.localflow=1 and S.min=1;
select count(*) from testcases where localflow=2;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.localflow=2 and S.min=1;
select count(*) from testcases where localflow=3;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.localflow=3 and S.min=1;
select count(*) from testcases where localflow=4;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.localflow=4 and S.min=1;
select count(*) from testcases where localflow=5;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.localflow=5 and S.min=1;
select count(*) from testcases where localflow=6;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.localflow=6 and S.min=1;
select count(*) from testcases where localflow=7;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.localflow=7 and S.min=1;

select count(*) from testcases where secondaryflow=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.secondaryflow=0 and S.min=1;
select count(*) from testcases where secondaryflow=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.secondaryflow=1 and S.min=1;
select count(*) from testcases where secondaryflow=2;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.secondaryflow=2 and S.min=1;
select count(*) from testcases where secondaryflow=3;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.secondaryflow=3 and S.min=1;
select count(*) from testcases where secondaryflow=4;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.secondaryflow=4 and S.min=1;
select count(*) from testcases where secondaryflow=5;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.secondaryflow=5 and S.min=1;
select count(*) from testcases where secondaryflow=6;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.secondaryflow=6 and S.min=1;
select count(*) from testcases where secondaryflow=7;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.secondaryflow=7 and S.min=1;

select count(*) from testcases where loopstructure=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.loopstructure=0 and S.min=1;
select count(*) from testcases where loopstructure=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.loopstructure=1 and S.min=1;
select count(*) from testcases where loopstructure=2;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.loopstructure=2 and S.min=1;
select count(*) from testcases where loopstructure=3;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.loopstructure=3 and S.min=1;
select count(*) from testcases where loopstructure=4;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.loopstructure=4 and S.min=1;
select count(*) from testcases where loopstructure=5;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.loopstructure=5 and S.min=1;
select count(*) from testcases where loopstructure=6;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.loopstructure=6 and S.min=1;

select count(*) from testcases where loopstructure=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.loopstructure=0 and S.min=1;
select count(*) from testcases where loopstructure=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.loopstructure=1 and S.min=1;
select count(*) from testcases where loopstructure=2;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.loopstructure=2 and S.min=1;
select count(*) from testcases where loopstructure=3;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.loopstructure=3 and S.min=1;
select count(*) from testcases where loopstructure=4;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.loopstructure=4 and S.min=1;

select count(*) from testcases where asynchrony=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.asynchrony=0 and S.min=1;
select count(*) from testcases where asynchrony=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.asynchrony=1 and S.min=1;
select count(*) from testcases where asynchrony=2;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.asynchrony=2 and S.min=1;
select count(*) from testcases where asynchrony=3;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.asynchrony=3 and S.min=1;

select count(*) from testcases where taint=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.taint=0 and S.min=1;
select count(*) from testcases where taint=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.taint=1 and S.min=1;
select count(*) from testcases where taint=2;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.taint=2 and S.min=1;
select count(*) from testcases where taint=3;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.taint=3 and S.min=1;
select count(*) from testcases where taint=5;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.taint=5 and S.min=1;

select count(*) from testcases where runtimeenvdep=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.runtimeenvdep=0 and S.min=1;
select count(*) from testcases where runtimeenvdep=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.runtimeenvdep=1 and S.min=1;

select count(*) from testcases where continuousdiscrete=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.continuousdiscrete=0 and S.min=1;
select count(*) from testcases where continuousdiscrete=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.continuousdiscrete=1 and S.min=1;

select count(*) from testcases where signedness=0;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.signedness=0 and S.min=1;
select count(*) from testcases where signedness=1;
select count(*) from testcases T,splint S where 
    T.name=S.name and T.signedness=1 and S.min=1;
