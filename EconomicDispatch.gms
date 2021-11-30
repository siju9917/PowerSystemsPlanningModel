****Simon Julien DCOPF*****
**IMPACT OF TOPOLOGY OF RENEWABLE GENERATORS AND STORAGE ON STABILITY**

*Max MIP relative Gap **Improtant for the built in solver
option optcr = 0.001;

sets
*initialize nodes
*IEEE 24 bus test system
n /n1*n24/
*establish reference node for phase angle tracking. Could be any node in the system
slack(n) /n3/
*initialize generators
*15 generators. IEEE has 10 so I have 5 more with some sharing a bus
G /g1*g15/

*Initialize storage on grid
*3 batteries
s /s1*s3/;

*initialize Synchronous generators specifically. Nuclear, Coal Steam, Coal 3 Stream, Oil Stream, Hydro
*not written as g1*g15 for easy interchangability between syncG and renG
set syncG(G) /g1,g2,g3,g5,g6,g7,g9,g10,g13,g15/;
*initialize Renewable generators specifically
*All curtailable solar plants
set renG(G) /g14,g11,g12,g8,g4/;

*alias is necessary to reference two nodes in one statement
alias(n,nn);

*per-unit base
scalar PUbase /100/;

*I will establish the network connections in games rather than reading in because they don't change much between versions of my code
*will stay exactly the same for all test cases

*establish generator connections to nodes
*Topology of generators connection to nodes does not change for entire project
set gen2bus (n,g)
/n1  . g1 
 n2  . g2 
 n7  . g3 
 n7  . g4 
 n13 . g5 
 n13 . g6 
 n23 . g7 
 n23 . g8 
 n22 . g9 
 n21 . g10 
 n18 . g11 
 n18 . g12 
 n16 . g13 
 n15 . g14 
 n15 . g15/;
 
*establish storage connections to nodes
*Storage is used for second research question where the changing topology of storage is changed here.
set s2bus (n,s)
/n5  . s3
 n19 . s1
 n22  . s2/;
 
*establish IEEE 24 bus network transmission connections (adjacent nodes)
set adjacency (n,nn)
/n1  . n2
 n1  . n3
 n1  . n5
 n2  . n4
 n2  . n6
 n3  . n9
 n3  . n24
 n4  . n9
 n5  . n10
 n6  . n10
 n7  . n8
 n8  . n9
 n8  . n10
 n9  . n12
 n9  . n11
 n10 . n11
 n10 . n12
 n11 . n14
 n11 . n13
 n12 . n13
 n12 . n23
 n13 . n23
 n14 . n16
 n15 . n16
 n15 . n21
 n15 . n24
 n16 . n17
 n16 . n19
 n17 . n18
 n17 . n22
 n18 . n21
 n19 . n20
 n20 . n23
 n21 . n22/;

*make transmission connections "undirected" (both ways) ie set to DC Power System approximations
adjacency(nn,n)$adjacency(n,nn)=1;

*extablish line reactance values and capacities
*Congestion and capacity data given in IEEE 24 bus data
*Congestion here is necessary for my project's investigation into topology of the power system
table linePar(n,nn,*)
            x       lim
n1  . n2    0.0146  175
n1  . n3    0.2253  175
n1  . n5    0.0907  350
n2  . n4    0.1356  175
n2  . n6    0.2050  175
n3  . n9    0.1271  175
n3  . n24   0.0840  400
n4  . n9    0.1110  175
n5  . n10   0.0940  350
n6  . n10   0.0642  175
n7  . n8    0.0652  350
n8  . n9    0.1762  175
n8  . n10   0.1762  175
n9  . n11   0.0840  400
n9  . n12   0.0840  400
n10 . n11   0.0840  400
n10 . n12   0.0840  400
n11 . n13   0.0488  500
n11 . n14   0.0426  500
n12 . n13   0.0488  500
n12 . n23   0.0985  500
n13 . n23   0.0884  500
n14 . n16   0.0594  500
n15 . n16   0.0172  500
n15 . n21   0.0249  1000
n15 . n24   0.0529  500
n16 . n17   0.0263  500
n16 . n19   0.0234  500
n17 . n18   0.0143  500
n17 . n22   0.1069  500
n18 . n21   0.0132  1000
n19 . n20   0.0203  1000
n20 . n23   0.0112  1000
n21 . n22   0.0692  500;

*Follow Bi-direction DC conditions for reactance
linePar(n,nn,'x')$(linePar(n,nn,'x')=0)=linePar(nn,n,'x');
*Follow Bi-direction DC conditions for MVA Cap
linePar(n,nn,'lim')$(linePar(n,nn,'lim')=0)=linePar(nn,n,'lim');
*Define susceptance B
*Could have defined this as another column in the table but this is faster
linePar(n,nn,'B')$adjacency(n,nn) = 1/linePar(n,nn,'x');


*Load percentagest of total load distributed across nodes
*Multiply these values by overall node for the hour to get load associated with each node
table load2bus(n,*)
    D
n1  0.038
n2  0.034
n3  0.063
n4  0.026
n5  0.025
n6  0.048
n7  0.044
n8  0.06
n9  0.061
n10 0.068
n11 0
n12 0
n13 0.093
n14 0.068
n15 0.111
n16 0.035
n17 0
n18 0.117
n19 0.064
n20 0.045
n21 0
n22 0
n23 0
n24 0;



*Initialize t for time (hours in week)
*24*7=168
set t /t1*t168/;
*Allow alias of tt for time if needed for reference of t and tt in the same statement
alias(t,tt);

*Storage parameters
*max storage per "battery"
parameter sCap(s)
/s1 92.0455
 s2 92.0455
 s3 153.409/;
 
*storage energy value.
*40% of energy at peak demand for overall system (which is peak in the summer)
parameter sEnergy(s)
/s1 368.182
 s2 368.182
 s3 613.636/;
 
*third battery is slightly more efficient because it has higher capacity which should correlate.
parameter sEff(s)
/s1 0.75
 s2 0.75
 s3 0.8/;

*Load time series data read in
*Time series file changes depending on the season I am focusing on
Table timeSeries(t,*)
$Ondelim
$include /Users/simon/Desktop/timeseriesSp.csv
$offdelim
;

*Generation data with a-i with same correspondence as in slide examples
*a-MMBTU/MWH heat rate
*b- MMBTU/hr base heat rate
*c- Max capacity
*d- minimum on capacity
*e- Max ramping cap
*f- Variable and Maintenace cost
*g- Start up costs
*h- Fuel price
*i- Min down time

*This File changes every Trial case
Table genPar(G,*)
$Ondelim
$include /Users/simon/Desktop/GenerationDataMS2.csv 
$offdelim
;


*define capacity factor for curtailable solar
*Changes everytime renewable topology changes
parameter capFact(renG,t);
capFact('g4',t)=timeSeries(t,'b');
capFact('g8',t)=timeSeries(t,'c');
capFact('g11',t)=timeSeries(t,'d');
capFact('g12',t)=timeSeries(t,'e');
capFact('g14',t)=timeSeries(t,'f');

*penalty to deter solution from using dumped and unserved energy
scalar penalty /10000000000/; 

*initialize general variables
*cost is objective function for minimizing
variables cost,flow(n,nn,t), phaseA(n,t);

*initialize variables with restrictions of must be positive values
positive variables genX(G,t), resX(G,t), unservedenergy(t,n), dumpenergy(t,n),soc(s,t), sgenX(s,t), sLoad(s,t);

*Initialize variables that can only have values 0 or 1 (ON OFF)
binary variables on(G,t), turnOn(G,t), turnOff(G,t);

*Initialize equations that are defined below
Equations costObj, rampUp, rampDown, reserves, maxGen, maxRes, minGen, onState,node_eq, powerFlow,minDownTime,sInitial,sCharge,sFinal,s_eq,sMaxGen,sMaxLoad,maxRenGen;

*Objective function: This rates the cost of running the current system and will be used to compare multiple cases and their outcomes
*Adds up all VO&M costs, fuel costs, startup costs, and unserved/dumped energy penalty costs.
costObj.. cost =e= sum((syncG,t),genPar(syncG,'f')*genX(syncG,t))+sum((syncG,t),genPar(syncG,'h')*(genPar(syncG,'a')*genX(syncG,t)+on(syncG,t)*genPar(syncG,'b')))+sum((syncG,t), turnOn(syncG,t)*genPar(syncG,'g'))+ sum((t,n), unservedenergy(t,n))*penalty +sum((t,n),dumpenergy(t,n))*penalty;

*Equilibrium equation, essentially says generation being generated + unserved energy must always equal congestion+ load+ dumped energy. 
node_eq(n,t).. sum(g$gen2bus(n,g), genX(G,t))+sum(s$s2bus(n,s), sgenX(s,t))-timeSeries(t,'L')*load2bus(n,'D')*0.8-sum(s$s2bus(n,s),sLoad(s,t))+unservedenergy(t,n)=e=sum(nn$adjacency(n,nn), flow(n,nn,t))+dumpenergy(t,n);

*Defining conjection that is used in equilibrium eq. Derivation shown in class.
powerFlow(n,nn,t)$adjacency(n,nn).. flow(n,nn,t) =e= linePar(n,nn,'B')*(phaseA(n,t)-phaseA(nn,t))*PUbase;

*ramping equations
*ramp up says generation increase of one timestep must be less than or equal to max ramping added to max generation.
rampUp(syncG,t)$(ord(t) GT 1).. genX(syncG,t) - genX(syncG,t-1) =l= on(syncG,t)*genPar(syncG,'e')+turnOn(syncG,t)*genPar(syncG,'d');
*similar eqauation but for ramp down
rampDown(syncG,t)$(ord(t) GT 1).. genX(syncG,t)-genX(syncG,t-1) =g= -on(syncG,t)*genPar(syncG,'e')-turnOff(syncG,t)*genPar(syncG,'d');

*define reserevs. sum of reserves for all generators must be more than or equal to load times a small value (0.03)- value used in class
reserves(t).. sum(syncG, resX(syncG,t)) =g= 0.48*0.03*timeSeries(t,'L');

*Limiting generation cannot exceed max capacity
maxGen(syncG,t).. genX(syncG,t) + resX(syncG,t) =l= on(syncG,t)*genPar(syncG,'c');

*Establish minimum generation if it is on
minGen(syncG,t).. genX(syncG,t) =g= on(syncG,t)*genPar(syncG,'d');

*Establish max reserves capped at 1/6 of ramping generation
maxRes(syncG,t).. resX(syncG,t) =l= on(syncG,t)*genPar(syncG,'e')/6;

*Max cap of renewable generation constraint
*cap includes the capacity factor of max gen
maxRenGen(renG,t)..  genX(renG,t) =l= genPar(renG,'c')*capFact(renG,t);

*Binary equation of on off defining what turn on and turn off mean. As a generator turns on, then turnOn =1 and so on
onState(G,t)$(ord(t) GT 1).. turnOn(G,t)-turnOff(G,t) =e= on(G,t) - on(G,t-1);

*Define how long a generator must be off once it is turned off
minDownTime(syncG,t)$(ord(t)>1).. 1-on(syncG,t) =g= sum(tt$(ord(tt)<=ord(t) and ord(tt)>(ord(t)-genPar(syncG,'i'))),turnOff(syncG,tt));

*Storage Constraints 
*State of charge for all three storages
*start at 50% storage
sInitial(s,t)$(ord(t) = 1).. soc(s,t) =e= 0.5*sEnergy(s);
*after t=1 state minus what is taken from storage plus what is stored
sCharge(s,t)$(ord(t)>1).. soc(s,t) =e= soc(s,t-1)-sgenX(s,t-1)+sEff(s)*sLoad(s,t-1);
*at final timestep 168...
sFinal(s,t)$(ord(t) = 168).. soc(s,t) =e= -sgenX(s,t)+sEff(s)*sLoad(s,t);
*cant give off more than what is already stored in storage
s_eq(s,t).. soc(s,t) =l= sEnergy(s);
*Max energy provided by storage
sMaxGen(s,t)..sgenX(s,t) =l= sCap(s);
*Max energy stored by storage
sMaxLoad(s,t).. sLoad(s,t) =l= sCap(s);

*Determine the Max power flow in the equation
flow.up(n,nn,t)$adjacency(n,nn) = linePar(n,nn,'lim');
*Define min (negative)
flow.lo(n,nn,t)$adjacency(n,nn) = -linePar(n,nn,'lim');

*Phase angle ranges
phaseA.lo(n,t) = -360;
phaseA.up(n,t) = 360;

*Establish reference node always has phase angle at 0. this is node 3
*All other phase angles are relative to this slack
phaseA.fx(slack,t) = 0;

*Dispatch Model
*Does not include storage eqations in first research quesetion
*Includes all eqations for second research question
Model dispatch /all/;

*Solve statement using MIP solver for linear series of equations
Solve dispatch us MIP min cost;

*parameters defined for easy reference in output files
parameters TOTCOST, LMP(n,t), LINEFLOW(n,nn,t), GENERATION(g), VANGLE(n,t);

LMP(n,t) = node_eq.m(n,t);
LINEFLOW(n,nn,t)$adjacency(n,nn) = flow.l(n,nn,t);
VANGLE(n,t) = phaseA.l(n,t);


*Display all main equations for easy debugging
Display cost.l, genX.l, resX.l, turnOn.l, unservedenergy.l, dumpenergy.l,on.l, turnOff.l, LMP, LINEFLOW, VANGLE;

*Cost output. I really only need the first value of this output becasue they are all the same for cost.l
File results /"/Users/simon/Desktop/results.txt"/;
put results;
loop((t,G), put t.tl, @12, G.tl, @24, cost.l:8:4 /);
putclose;


*angle time series output for every generator. 
File fake /"/Users/simon/Desktop/fake.txt"/;
put fake;
loop((t,n), put t.tl, @12, n.tl, @24, phaseA.l(n,t):8:4 /);
putclose;


























