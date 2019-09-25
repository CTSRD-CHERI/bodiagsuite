use thesis;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.writeread=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.writeread=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.writeread=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.writeread=1 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.whichbound=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.whichbound=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.whichbound=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.whichbound=1 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.indexcomplex=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.indexcomplex=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.indexcomplex=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.indexcomplex=1 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.indexcomplex=2;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.indexcomplex=2 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.indexcomplex=3;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.indexcomplex=3 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.indexcomplex=4;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.indexcomplex=4 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.indexcomplex=5;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.indexcomplex=5 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.indexcomplex=6;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.indexcomplex=6 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.memloc=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.memloc=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.memloc=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.memloc=1 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.memloc=2;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.memloc=2 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.memloc=3;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.memloc=3 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.memloc=4;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.memloc=4 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.scope=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.scope=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.scope=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.scope=1 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.scope=2;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.scope=2 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.scope=3;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.scope=3 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.container=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.container=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.container=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.container=1 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.container=2;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.container=2 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.container=3;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.container=3 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.container=4;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.container=4 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.container=5;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.container=5 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.pointer=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.pointer=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.pointer=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.pointer=1 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.indexcomplex=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.indexcomplex=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.indexcomplex=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.indexcomplex=1 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.indexcomplex=2;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.indexcomplex=2 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.indexcomplex=3;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.indexcomplex=3 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.indexcomplex=4;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.indexcomplex=4 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.indexcomplex=5;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.indexcomplex=5 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.indexcomplex=6;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.indexcomplex=6 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.addrcomplex=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.addrcomplex=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.addrcomplex=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.addrcomplex=1 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.addrcomplex=2;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.addrcomplex=2 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.addrcomplex=3;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.addrcomplex=3 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.addrcomplex=4;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.addrcomplex=4 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.addrcomplex=5;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.addrcomplex=5 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.lencomplex=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.lencomplex=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.lencomplex=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.lencomplex=1 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.lencomplex=2;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.lencomplex=2 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.lencomplex=3;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.lencomplex=3 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.lencomplex=4;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.lencomplex=4 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.lencomplex=5;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.lencomplex=5 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.lencomplex=6;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.lencomplex=6 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.lencomplex=7;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.lencomplex=7 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.aliasaddr=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.aliasaddr=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.aliasaddr=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.aliasaddr=1 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.aliasaddr=2;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.aliasaddr=2 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.aliasindex=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.aliasindex=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.aliasindex=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.aliasindex=1 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.aliasindex=2;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.aliasindex=2 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.aliasindex=3;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.aliasindex=3 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.localflow=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.localflow=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.localflow=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.localflow=1 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.localflow=2;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.localflow=2 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.localflow=3;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.localflow=3 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.localflow=4;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.localflow=4 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.localflow=5;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.localflow=5 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.localflow=6;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.localflow=6 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.localflow=7;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.localflow=7 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.secondaryflow=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.secondaryflow=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.secondaryflow=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.secondaryflow=1 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.secondaryflow=2;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.secondaryflow=2 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.secondaryflow=3;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.secondaryflow=3 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.secondaryflow=4;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.secondaryflow=4 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.secondaryflow=5;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.secondaryflow=5 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.secondaryflow=6;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.secondaryflow=6 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.secondaryflow=7;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.secondaryflow=7 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.loopstructure=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.loopstructure=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.loopstructure=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.loopstructure=1 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.loopstructure=2;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.loopstructure=2 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.loopstructure=3;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.loopstructure=3 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.loopstructure=4;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.loopstructure=4 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.loopstructure=5;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.loopstructure=5 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.loopstructure=6;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.loopstructure=6 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.loopstructure=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.loopstructure=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.loopstructure=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.loopstructure=1 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.loopstructure=2;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.loopstructure=2 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.loopstructure=3;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.loopstructure=3 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.loopstructure=4;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.loopstructure=4 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.asynchrony=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.asynchrony=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.asynchrony=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.asynchrony=1 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.asynchrony=2;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.asynchrony=2 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.asynchrony=3;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.asynchrony=3 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.taint=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.taint=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.taint=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.taint=1 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.taint=2;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.taint=2 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.taint=3;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.taint=3 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.taint=5;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.taint=5 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.runtimeenvdep=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.runtimeenvdep=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.runtimeenvdep=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.runtimeenvdep=1 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.continuousdiscrete=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.continuousdiscrete=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.continuousdiscrete=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.continuousdiscrete=1 and U.min=1 and U.ok=1;

select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.signedness=0;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.signedness=0 and U.min=1 and U.ok=1;
select count(*) from testcases T,uno U where T.name=U.name and U.min=1 and T.signedness=1;
select count(*) from testcases T,uno U where 
    T.name=U.name and T.signedness=1 and U.min=1 and U.ok=1;
