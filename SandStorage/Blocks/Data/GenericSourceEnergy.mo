within SandStorage.Blocks.Data;
record GenericSourceEnergy
  "Base class for source energy conversion factors"
  extends Modelica.Icons.Record;
  parameter Real rEle=0 "Conversion factor for electricity";
  parameter Real rNatGas=0 "Conversion factor for natural gas";
  parameter Real rOil=0 "Conversion factor for fuel oil (1,2,3,4,5,6,diesel,karosene)";
  parameter Real rPro=0 "Conversion factor for propane and liquid propane";
  parameter Real rSte=0 "Conversion factor for steam";
  parameter Real rHotWat=0 "Conversion factor for hot water";
  parameter Real rChiWat=0 "Conversion factor for chilled water";
  parameter Real rCoa=0 "Conversion factor for coal";
  parameter Real rBio=0 "Conversion factor for biofuel";
  parameter Real rOth=0 "Conversion factor for other sources";
  final parameter Real r[10]=
    {rEle,rNatGas,rOil,rPro,rSte,rHotWat,rChiWat,rCoa,rBio,rOth}
    "Conversion factors";
  annotation (preferredView="info",
  Documentation(info="<html>
<p>
This is the base record for source energy conversion factors.
</p>
</html>",
revisions="<html>
<ul>
<li>
January 10, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>"));
end GenericSourceEnergy;
