package frictionLosses;
use Exporter;
@ISA = ('Exporter');
@EXPORT = ('calcLosses');
no warnings;
#	Algorithm checked against 'Bausteine der Heizungstechnik, Glück 1988, pp. 146' [jk,29.06.15]

sub calcLosses{
	$pi = 3.14159265359;
	$R = 287.058;##dry air, modify if needed.
	$massFlow = shift;
	$pressure = shift;
	$temp = shift;
	$polytropicExponent = shift;
	$pressure = $pressure*10**5;
	$density = $pressure/($temp*$R);
	$literToKgConversion = 0.001/60*$density;
	$massFlow = $massFlow*$literToKgConversion;
	@inputParam = @_;
	$i = 0;
	foreach my $params (@inputParam){
		@values = ();
		foreach my $param (@{$params}){
			push(@values,$param);
		}
	determinePart(@values);
	@values = ();
	$i++;
	}
	return $pressureAfterPart;
}

sub determinePart{
	$type = shift;
	@paramsOfPart = @_;
	if($i == 0){
		$pressureAfterPart = $pressure;
		$pressureInlet = $pressure;
	}
	else{
		$pressureInlet = $pressureAfterPart;
	}
	if($type eq "P"){
		calcLossPipe(@paramsOfPart);
	}
	elsif($type eq "R"){
		if($i ==0){
			print "Cannot start with resistance!  Exit\n";
			exit;
		}
		calcLossResistance(@paramsOfPart);
	}
	else{
		print "Wrong pipe part!\n exit.";
		exit;
	}
}

sub calcLossPipe{
	$length = shift;
	$diameter = shift;
	$roughness = shift;
	$dynamicViscosity = 1.716*10**(-5)*($temp/273.15)**(3/2)*383.55/($temp+110.4);
	$specificVolume = $R*$temp/$pressureAfterPart;
	$meanVelocity = 4*$massFlow*$specificVolume/($pi*$diameter**2);
	$reynoldsNumber = 4*$massFlow/($dynamicViscosity*$pi*$diameter);
	$relativelyRoughness = $roughness/$diameter;
	calcIntersection();
	$parabolaExponent = 1/sqrt($lambda);
	$correctedKineticEnergyFactor = 0.25 * ((1/$parabolaExponent + 2)**3 * (1/$parabolaExponent + 1)**3)/((3/$parabolaExponent+1)*(3/$parabolaExponent+2));
	for(my $j = 0; $j <= 8 ; $j++){
		if($polytropicExponent == 1){
			isothermicPipeAlgorithm();
		}
	}
	print "Pressure after pipe: $pressureAfterPart Pa\n";
}

sub calcIntersection{
	#print "Starting newton's method.\nIf there is no solution in a few seconds, than you have to customize the input in this module.\n";
	$c = $roughness/(3.71*$diameter);
	$lambdastart = 1;
	$lambda = $lambdastart;
	for(my $j = 0; $j <=10; $j++){
		fun($lambda);
		$lambda = $lambda-$fun/$derivFun;
		if($lambda < 0){
			$lambdastart = $lambdastart-0.01;
			$lambda = $lambdastart;
			$j = 0;
		}
	}
}

sub fun{
	$xn = shift;
	$fun = 1/sqrt($xn) + 2*log10(2.51/($reynoldsNumber*sqrt($xn)) + $c);
	$derivFun = (sqrt($xn)*(-0.5*$reynoldsNumber*$c-2.51)-1.255)/($reynoldsNumber*$c*$xn**2+2.51*$xn**(3/2));
}

sub isothermicPipeAlgorithm(){
		#print $pressureInlet, "\n";
		$pressureAfterPartSquared = $pressureInlet**2-$pressureInlet*$meanVelocity**2/($specificVolume)*($lambda*$length/$diameter+2*$correctedKineticEnergyFactor*log($pressureInlet/$pressureAfterPart));
		if($pressureAfterPartSquared > 0){
			$pressureAfterPart = sqrt($pressureAfterPartSquared);
		}
		else{
			$pressureAfterPart = 0;
			last;
		}
}

sub calcLossResistance{
	my $diameter1 = shift;
	my $diameter2 = shift;
	calcLossesJumpingResistance($diameter1,$diameter2);
	$deltaPResistance = $zeta * $meanVelocity**2/2*$density;
	$pressureAfterPart = $pressureAfterPart - $deltaPResistance;
	print "Pressure after resistance: $pressureAfterPart Pa\n";
}

sub calcLossesJumpingResistance{
	my $d1 = shift;
	my $d2 = shift;
	if($d1 > $d2){
		my $mu =1/(1+0.707*sqrt(1-($d2/$d1)**2));
		$zeta = (1-1/$mu)**2;
	}
	else{
		$zeta = (1-($d1/$d2)**2)**2;
	}
}

sub log10{
	$n = shift;
	return log($n)/log(10);
}
