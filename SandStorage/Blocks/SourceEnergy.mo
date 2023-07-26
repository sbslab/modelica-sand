within SandStorage.Blocks;
model SourceEnergy
"KPI for source energy"
  extends Modelica.Blocks.Interfaces.SO(y(unit="J/m2"));
  parameter Integer n(final min=1)=1 "Number of sources";
  parameter Modelica.Units.SI.Area A(final min=0)
    "Total floor area of building";
  parameter Data.GenericSourceEnergy conFac
    "Primary source energy conversion factors"
    annotation (Placement(transformation(extent={{60,60},{80,80}})));
  Modelica.Blocks.Math.Gain to_J_A(k=1/A) "Normalize by floor area"
    annotation (Placement(transformation(extent={{60,-10},{80,10}})));
  Modelica.Blocks.Continuous.Integrator ESit[n](each y(unit="J")) "Energy"
    annotation (Placement(transformation(extent={{-80,-10},{-60,10}})));
  Modelica.Blocks.Interfaces.RealInput PSit[n](each unit="W")
    "Power at the site (n number of sources)"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
  Modelica.Blocks.Interfaces.IntegerInput typSou[n]
    "Type of energy source: 1=Ele, 2=NatGas, 3=Oil, 4=Pro, 5=Ste,
    6=HotWat, 7=ChiWat, 8=Coa, 9=Bio, 10=Oth"
    annotation (Placement(transformation(extent={{-140,40},{-100,80}})));
  Modelica.Blocks.Sources.RealExpression r[n](y=
     {conFac.r[typSou[i]] for i in 1:n})
    "Conversion factors for each energy source"
    annotation (Placement(transformation(extent={{-60,30},{-40,50}})));
  Modelica.Blocks.Math.Product ESou[n]
    "Source energy for each individual input"
    annotation (Placement(transformation(extent={{0,-10},{20,10}})));
  Modelica.Blocks.Math.MultiSum ESouTot(final k=fill(1, n), final nu=n)
    "Total source energy (all inputs)"
    annotation (Placement(transformation(extent={{34,-6},{46,6}})));
equation
  connect(PSit, ESit.u)
    annotation (Line(points={{-120,0},{-82,0}}, color={0,0,127}));
  connect(ESou.y, ESouTot.u)
    annotation (Line(points={{21,0},{34,0}}, color={0,0,127}));
  connect(ESouTot.y, to_J_A.u)
    annotation (Line(points={{47.02,0},{58,0}}, color={0,0,127}));
  connect(to_J_A.y, y)
    annotation (Line(points={{81,0},{110,0}}, color={0,0,127}));
  connect(ESit.y, ESou.u2) annotation (Line(points={{-59,0},{-10,0},{-10,-6},{-2,
          -6}}, color={0,0,127}));
  connect(r.y, ESou.u1) annotation (Line(points={{-39,40},{-8,40},{-8,6},{-2,6}},
        color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    Documentation(revisions="<html>
<ul>
<li>
June 9, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>", info="<html>
<p>
Calculates the source energy from site energy and site-to-source conversion factor(s).
</p>
</html>"));
end SourceEnergy;
