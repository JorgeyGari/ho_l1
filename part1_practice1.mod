#
# Practice 1: Linear Programming - Heuristics and Optimization
#
# Optimal solution to minimize cost
#
# Part 1
#

/* ------ SETS ------ */

/* set of nodes */
set NODES;

/* set of stops */
set STOPS;


/* ------ PARAMETERS ------ */

/* kilometers for going to each stop from each stop */
param km {i in NODES, j in NODES};

/* students in each stop */
param students {s in NODES};

/* constant parameters */
param cost_per_km;
param cost_per_bus;
param capacity;
param number_buses;


/* ------ VARIABLES ------*/

/* decision variable representing the paths traversed by the buses */
var x {i in NODES, j in NODES} >= 0, binary;

/* decision variable representing the flux of students */
var f {i in NODES, j in NODES} >= 0;


/* ------ OBJETCTIVE FUNCTION ------ */
minimize mincosts: sum{j in NODES} x["Parking", j] * cost_per_bus + cost_per_km * sum{i in NODES, j in NODES} km[i, j] * x[i, j];


/* ------ CONSTRAINTS ------ */

/* control the number of buses used (buses leaving parking = buses arriving at school) */
s.t. buses_used : sum{j in NODES} x["Parking", j] = sum{i in NODES} x[i, "School"];

/* maximum number of buses available */
s.t. maximum_buses : sum{j in NODES} x["Parking", j] <= 3;

/* number of buses that arrive at each node */
s.t. arrival {s in STOPS} : sum{i in NODES} x[i, s] = 1;

/* number of buses that leave each node */
s.t. departure {s in STOPS} : sum{j in NODES} x[s, j] = 1;

/* number of students in the bus = previous students in the bus + students hopping in */
s.t. control_flow {s in STOPS} : sum{j in NODES} f[s, j] = sum{i in NODES} f[i, s] + students[s];

/* the flux can never be bigger than the capacity (when the bus traverses that stop, otherwise it will be 0) */
s.t. flow_accum {i in NODES, j in NODES}: f[i,j] <= capacity * x[i,j];

solve;

end;
