#!/usr/bin/perl -w
use frictionLosses;
#Tool for calculating fraction losses in tubes due to pipe roughness and resistance (e.g. narrowing)
# Version 1.0 [29 Jun 2015, jk]
#
#using parts with the following notation:
#	1st entry is massflow in [lit/min],
#	2nd entry is pressure in [bar],
#	3rd entry is entrance temperature in [K],
#	4th entry is the polytropic exponent, e.g. for isothermic processes it is 1,
#	following entries are the parameterization of the tube parts regarding this syntax:
#		pipe: 		['P',LENGTH,DIAMETER,ROUGHNESS]
#		resistance:	['R',DIAMETER1,DIAMETER2]
#	Note that this version only covers the calculation for isothermic conditions regarding temperature calculation
#	after each part. May be updated in further versions.
#	Algorithm checked against 'Bausteine der Heizungstechnik, Glück 1988, pp. 146' [29 Jun 2015,jk]
#
#	useful pipe diameter:
#		 1/4" = 0.00635 m;	1/8 " = 0.003175 m;	1/16" = 0.0015875 m;
#example:	
my @parts = (1.4,1,293,1,[ 'P',0.1,0.00635,0.000001], [ 'R', 0.1, 0.001 ],['P',1500,0.1,0.01]);
$pressure  = calcLosses(@parts);
#pressure is the total pressure - friction losses in [Pa] after your parameterization. Use it as you like.
