#
# Practice 1: Linear Programming - Heuristics and Optimization
#
# Optimal solution to minimize cost
#
# Part 2
#

/* ------ SETS ------ */

/* set of nodes where the bus passes through */
set NODES;

/* set of stops where students can be picked up */
set STOPS;

/* set of students */
set STUDENTS;


/* ------ PARAMETERS ------ */

/* kilometers to go to each stop from each stop */
param km {i in NODES, j in NODES};

/* stops where each student can take the bus */
param assignments {e in STUDENTS, s in STOPS}, binary;

/* students in each stop */
param siblings {e in STUDENTS, t in STUDENTS}, binary;

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

/* decision variable representing the stop assigned to each students */
var a {i in STOPS, j in STUDENTS} >= 0, binary;
# we add this decision variable to be able to assign the stops to the students.


/* ------ OBJETCTIVE FUNCTION ------ */
minimize mincosts: sum{j in NODES} x["Parking", j] * cost_per_bus + cost_per_km * sum{i in NODES, j in NODES} km[i, j] * x[i, j];


/* ------ RESTRICTIONS ------ */

/* control the number of buses used (# buses leaving parking = # buses arriving at school) */
s.t. buses_used : sum{j in NODES} x["Parking", j] = sum{i in NODES} x[i, "School"];

/* maximum number of buses available */
s.t. maximum_buses : sum{j in NODES} x["Parking", j] <= 3;

/* number of buses that arrive at each node */
s.t. arrival {s in STOPS} : sum{i in NODES} x[i, s] <= 1;

/* number of buses that leave each node */
s.t. departure {s in STOPS} : sum{j in NODES} x[s, j] <= 1;

/* number of students in the bus = previous students in the bus + students hopping in */
s.t. control_flow {s in STOPS} : sum{j in NODES} f[s, j] = sum{i in NODES} f[i, s] + sum{e in STUDENTS} a[s, e];
# we now take the number of students hopping in from the decision variable a instead of the parameter students

/* the flux can never be bigger than the capacity (when we are making that stop, otherwise it will be 0) */
s.t. flow_accum {i in NODES, j in NODES}: f[i,j] <= capacity * x[i,j];

# new restrictions

/* the students in each stop cannot be greater than the capacity of each bus */
s.t. students_per_stop {s in STOPS} : sum{i in STUDENTS} a[s, i] <= capacity;

/* each student has to be assigned to one and only one stop */
s.t. stops_per_student {e in STUDENTS} : sum{j in STOPS} a[j, e] = 1;

/* control that a stop where a student cannot go to is not assigned to that student */
s.t. control_students {s in STOPS, e in STUDENTS} : a[s, e] <= assignments[e, s];

/* students who are siblings go to the same stop */
s.t. siblings_together {e in STUDENTS, t in STUDENTS, s in STOPS} : (a[s, e] - a[s, t]) * siblings[e, t] = 0;

solve;

end;